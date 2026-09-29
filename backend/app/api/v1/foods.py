import io
import os
from typing import Optional

from fastapi import APIRouter, Depends, File, Query, UploadFile, status
from PIL import Image, ImageOps
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db, get_detector
from app.core.config import settings
from app.core.errors import AppError
from app.ml.detector import FoodDetector
from app.models.user import User
from app.schemas.food import (
    DetectFoodResponse,
    FoodDetailResponse,
    FoodItemResponse,
    FoodListResponse,
)
from app.services.food_service import get_food_by_id, list_foods
from app.services.scanner_service import process_detections

router = APIRouter(prefix="/foods", tags=["Foods & Scanner"])

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_PIXELS = 25_000_000


@router.get(
    "",
    response_model=FoodListResponse,
    status_code=status.HTTP_200_OK,
    summary="Daftar makanan yang tersedia dengan opsi pencarian",
)
def get_foods(
    q: Optional[str] = Query(None, description="Pencarian nama makanan"),
    page: int = Query(1, ge=1, description="Nomor halaman"),
    page_size: int = Query(20, ge=1, le=100, description="Jumlah item per halaman"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    items, total = list_foods(db, q=q, page=page, page_size=page_size)
    response_items = [
        FoodItemResponse(
            id=f.id,
            name=f.name,
            calories_kcal_per_100g=float(f.nutrition.calories_kcal),
            protein_g_per_100g=float(f.nutrition.protein_g),
            carbs_g_per_100g=float(f.nutrition.carbs_g),
            fat_g_per_100g=float(f.nutrition.fat_g),
        )
        for f in items
    ]
    return FoodListResponse(items=response_items, page=page, page_size=page_size, total=total)


@router.get(
    "/{food_id}",
    response_model=FoodDetailResponse,
    status_code=status.HTTP_200_OK,
    summary="Detail makanan beserta data gizi per 100g",
)
def get_food(
    food_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    food = get_food_by_id(db, food_id)
    return FoodDetailResponse(
        id=food.id,
        name=food.name,
        calories_kcal_per_100g=float(food.nutrition.calories_kcal),
        protein_g_per_100g=float(food.nutrition.protein_g),
        carbs_g_per_100g=float(food.nutrition.carbs_g),
        fat_g_per_100g=float(food.nutrition.fat_g),
        source=food.nutrition.source,
    )


@router.post(
    "/detect",
    response_model=DetectFoodResponse,
    status_code=status.HTTP_200_OK,
    summary="Deteksi makanan dari foto menggunakan YOLO26n",
)
def detect_food(
    image: UploadFile = File(..., description="File foto makanan"),
    current_user: User = Depends(get_current_user),
    detector: FoodDetector = Depends(get_detector),
    db: Session = Depends(get_db),
):
    """
    Synchronous endpoint (def) per Architecture Decision AD-03 to run CPU-bound
    image validation and YOLO26n inference in the threadpool without blocking event loop.
    """
    # 1. Check filename
    if not image or not image.filename:
        raise AppError(
            status_code=status.HTTP_400_BAD_REQUEST,
            code="MISSING_FILE",
            message="File foto makanan wajib disertakan.",
        )

    # 2. Check extension
    _, ext = os.path.splitext(image.filename.lower())
    if ext not in ALLOWED_EXTENSIONS:
        raise AppError(
            status_code=status.HTTP_400_BAD_REQUEST,
            code="UNSUPPORTED_IMAGE_TYPE",
            message="Format file tidak didukung. Gunakan JPEG, PNG, atau WebP.",
        )

    # 3. Check Content-Type
    if image.content_type not in ALLOWED_MIME_TYPES:
        raise AppError(
            status_code=status.HTTP_400_BAD_REQUEST,
            code="UNSUPPORTED_IMAGE_TYPE",
            message="Content-Type file tidak didukung.",
        )

    # 4. Stream-read and enforce size limit
    max_bytes = settings.MAX_UPLOAD_SIZE_MB * 1024 * 1024
    content = bytearray()
    chunk_size = 64 * 1024  # 64 KB chunks

    while True:
        chunk = image.file.read(chunk_size)
        if not chunk:
            break
        content.extend(chunk)
        if len(content) > max_bytes:
            raise AppError(
                status_code=status.HTTP_400_BAD_REQUEST,
                code="FILE_TOO_LARGE",
                message=f"Ukuran file melebihi batas maksimum {settings.MAX_UPLOAD_SIZE_MB} MB.",
            )

    if len(content) == 0:
        raise AppError(
            status_code=status.HTTP_400_BAD_REQUEST,
            code="INVALID_IMAGE",
            message="File gambar kosong.",
        )

    # 5. Verify image content with Pillow
    try:
        pil_image = Image.open(io.BytesIO(content))
        pil_image.verify()

        # Re-open after verify() as verify() can invalidate state
        pil_image = Image.open(io.BytesIO(content))
        if pil_image.format not in ("JPEG", "PNG", "WEBP"):
            raise ValueError("Format tidak valid.")

        # Decompression bomb prevention
        w, h = pil_image.size
        if w * h > MAX_IMAGE_PIXELS:
            raise AppError(
                status_code=status.HTTP_400_BAD_REQUEST,
                code="INVALID_IMAGE",
                message="Dimensi resolusi gambar terlalu besar.",
            )

        # Convert to RGB
        pil_image = ImageOps.exif_transpose(pil_image)
        if pil_image.mode != "RGB":
            pil_image = pil_image.convert("RGB")
    except AppError:
        raise
    except Exception:
        raise AppError(
            status_code=status.HTTP_400_BAD_REQUEST,
            code="INVALID_IMAGE",
            message="Isi berkas bukan gambar yang valid atau rusak.",
        ) from None

    # 6. Check detector availability
    if not detector.is_available:
        raise AppError(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code="MODEL_UNAVAILABLE",
            message="Model deteksi makanan belum tersedia pada server.",
        )

    # 7. Run inference
    try:
        raw_detections = detector.detect(pil_image)
    except Exception:
        raise AppError(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            code="INTERNAL_SERVER_ERROR",
            message="Terjadi kesalahan saat memproses gambar.",
        ) from None

    # 8. Process detections via scanner_service
    processed = process_detections(db, raw_detections)
    return processed
