import io
import logging
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Union

from PIL import Image, ImageOps

from app.core.config import settings
from app.ml.exceptions import (
    CorruptImageError,
    ImageTooLargeError,
    InferenceFailureError,
    InvalidImageError,
    ModelNotAvailableError,
    UnsupportedImageFormatError,
)

logger = logging.getLogger("nutriview.ml")

ALLOWED_FORMATS: Set[str] = {"JPEG", "PNG", "WEBP"}
MAX_IMAGE_PIXELS: int = 25_000_000
DEFAULT_WEIGHTS_PATH: Path = Path(__file__).resolve().parent / "weights" / "best.pt"


def resolve_model_path(model_path: Optional[Union[str, Path]] = None) -> Path:
    """
    Resolves the model weight path in a portable manner.
    Checks:
    1. Explicit model_path if provided.
    2. Default weights directory relative to this module: app/ml/weights/best.pt.
    3. settings.MODEL_PATH.
    """
    if model_path:
        p = Path(model_path)
        if p.is_absolute() and p.exists():
            return p
        # Check relative to ml module directory
        ml_dir = Path(__file__).resolve().parent
        if (ml_dir / p).exists():
            return (ml_dir / p).resolve()
        if (ml_dir / "weights" / p.name).exists():
            return (ml_dir / "weights" / p.name).resolve()
        # Check relative to cwd
        if p.exists():
            return p.resolve()
        return p

    # Default portable path relative to app/ml/weights/best.pt
    if DEFAULT_WEIGHTS_PATH.exists():
        return DEFAULT_WEIGHTS_PATH.resolve()

    # Fallback to configured settings path
    settings_path = Path(getattr(settings, "MODEL_PATH", "app/ml/weights/best.pt"))
    if settings_path.is_absolute() and settings_path.exists():
        return settings_path
    if settings_path.exists():
        return settings_path.resolve()

    return DEFAULT_WEIGHTS_PATH


class DetectionResult(dict):
    """
    Structured detection result representing:
    {
        "detections": [
            {
                "class_id": int,
                "class_name": str,
                "confidence": float,
                "bbox": {"x1": int, "y1": int, "x2": int, "y2": int}
            }
        ]
    }
    Inherits from dict for seamless JSON serialization and dictionary access.
    """

    def __init__(self, detections: List[Dict[str, Any]]):
        super().__init__(detections=detections)

    @property
    def detections(self) -> List[Dict[str, Any]]:
        return self["detections"]


class YOLOInferenceService:
    """
    YOLO26n Food Detection Inference Service.

    Sole responsibilities (docs/ai.md §12):
    1. Load YOLO26n model once at application startup (persistent instance).
    2. Receive and validate images (format, size, corruption, pixel limits).
    3. Execute YOLO26n object detection inference.
    4. Extract bounding boxes (x1, y1, x2, y2), class IDs, class names, and confidence scores.
    5. Return structured detection results.

    Negative boundaries:
    - NO calorie, protein, carbs, or fat calculation.
    - NO nutrition target calculation.
    - NO portion estimation.
    - NO meal tracking.
    - NO database access.
    - NO user business logic.
    """

    def __init__(
        self,
        model_path: Optional[Union[str, Path]] = None,
        model_family: Optional[str] = None,
        confidence_threshold: Optional[float] = None,
        max_upload_size_mb: Optional[int] = None,
    ):
        raw_path = str(model_path) if model_path is not None else settings.MODEL_PATH
        self.model_path: str = raw_path
        self.resolved_path: Path = resolve_model_path(raw_path)
        self.model_family: str = model_family or getattr(settings, "MODEL_FAMILY", "YOLO26n")
        self.confidence_threshold: float = (
            confidence_threshold
            if confidence_threshold is not None
            else getattr(settings, "DETECTION_MIN_CONFIDENCE", 0.25)
        )
        self.max_file_size_bytes: int = (
            (max_upload_size_mb or getattr(settings, "MAX_UPLOAD_SIZE_MB", 5)) * 1024 * 1024
        )
        self.max_image_pixels: int = MAX_IMAGE_PIXELS

        self.model = None
        self._is_available: bool = False
        self._load_count: int = 0
        self._load_model()

    def _load_model(self) -> None:
        """
        Loads the YOLO26n model weights from disk once into memory.
        """
        if not self.resolved_path.exists():
            logger.warning(
                f"{self.model_family} weights not found at '{self.resolved_path}' "
                f"(configured: '{self.model_path}'). Inference service is unavailable."
            )
            self._is_available = False
            self.model = None
            return

        try:
            from ultralytics import YOLO

            self.model = YOLO(str(self.resolved_path))
            self._is_available = True
            self._load_count += 1
            logger.info(
                f"{self.model_family} model successfully loaded from '{self.resolved_path}' "
                f"(load count: {self._load_count})."
            )
        except Exception as e:
            logger.error(
                f"Failed to load {self.model_family} model from '{self.resolved_path}': {e}"
            )
            self._is_available = False
            self.model = None

    @property
    def is_available(self) -> bool:
        return self._is_available

    @property
    def load_count(self) -> int:
        return self._load_count

    def validate_and_prepare_image(
        self,
        image: Union[Image.Image, bytes, bytearray, io.BytesIO, str, Path],
    ) -> Image.Image:
        """
        Validates input image for:
        - Correct input type
        - Non-empty content
        - Allowed size limits
        - Supported format (JPEG, PNG, WebP)
        - Non-corrupt content (Pillow verify)
        - Decompression bomb prevention
        - Converts color profile to RGB
        """
        if image is None:
            raise InvalidImageError("Image input cannot be None.")

        if isinstance(image, Image.Image):
            w, h = image.size
            if w * h > self.max_image_pixels:
                raise ImageTooLargeError(
                    f"Image resolution {w}x{h} ({w * h} pixels) exceeds maximum allowed "
                    f"{self.max_image_pixels} pixels."
                )
            if image.format and image.format.upper() not in ALLOWED_FORMATS:
                raise UnsupportedImageFormatError(
                    f"Unsupported image format: {image.format}."
                )
            pil_img = ImageOps.exif_transpose(image)
            if pil_img.mode != "RGB":
                pil_img = pil_img.convert("RGB")
            return pil_img

        raw_bytes: bytes
        if isinstance(image, (bytes, bytearray)):
            raw_bytes = bytes(image)
        elif isinstance(image, io.BytesIO):
            raw_bytes = image.getvalue()
        elif isinstance(image, (str, Path)):
            p = Path(image)
            if not p.exists():
                raise InvalidImageError(f"Image file does not exist: {p}")
            if p.stat().st_size > self.max_file_size_bytes:
                raise ImageTooLargeError(
                    f"Image file size ({p.stat().st_size} bytes) exceeds limit of "
                    f"{self.max_file_size_bytes} bytes."
                )
            raw_bytes = p.read_bytes()
        else:
            raise InvalidImageError(
                f"Unsupported image input type: {type(image)}."
            )

        if len(raw_bytes) == 0:
            raise InvalidImageError("Image content is empty.")

        if len(raw_bytes) > self.max_file_size_bytes:
            raise ImageTooLargeError(
                f"Image file size ({len(raw_bytes)} bytes) exceeds limit of "
                f"{self.max_file_size_bytes} bytes."
            )

        try:
            stream = io.BytesIO(raw_bytes)
            pil_img = Image.open(stream)
            fmt = (pil_img.format or "").upper()
            if fmt not in ALLOWED_FORMATS:
                raise UnsupportedImageFormatError(
                    f"Unsupported image format '{fmt}'."
                )
            pil_img.verify()

            # Re-open after verify() to reset read pointer & decode raster
            stream.seek(0)
            pil_img = Image.open(stream)

            w, h = pil_img.size
            if w * h > self.max_image_pixels:
                raise ImageTooLargeError(
                    f"Image resolution {w}x{h} ({w * h} pixels) exceeds maximum allowed "
                    f"{self.max_image_pixels} pixels."
                )

            pil_img = ImageOps.exif_transpose(pil_img)
            if pil_img.mode != "RGB":
                pil_img = pil_img.convert("RGB")

            return pil_img
        except (UnsupportedImageFormatError, ImageTooLargeError, InvalidImageError):
            raise
        except Exception as e:
            raise CorruptImageError(f"Corrupt or unreadable image data: {e}") from e

    def detect(
        self,
        image: Union[Image.Image, bytes, bytearray, io.BytesIO, str, Path],
        confidence_threshold: Optional[float] = None,
    ) -> DetectionResult:
        """
        Runs YOLO26n food detection inference.

        Returns structured detection result:
        {
            "detections": [
                {
                    "class_id": 1,
                    "class_name": "Ayam Goreng",
                    "confidence": 0.91,
                    "bbox": {
                        "x1": 100,
                        "y1": 80,
                        "x2": 420,
                        "y2": 350
                    }
                }
            ]
        }
        """
        if not self._is_available or self.model is None:
            raise ModelNotAvailableError(
                f"{self.model_family} model is not available."
            )

        validated_image = self.validate_and_prepare_image(image)

        conf = (
            confidence_threshold
            if confidence_threshold is not None
            else self.confidence_threshold
        )

        try:
            results = self.model.predict(
                source=validated_image,
                conf=conf,
                verbose=False,
            )
        except Exception as e:
            logger.error(f"Inference failure in {self.model_family}: {e}")
            raise InferenceFailureError(f"YOLO inference failed: {e}") from e

        detections: List[Dict[str, Any]] = []
        for result in results:
            boxes = getattr(result, "boxes", None)
            if boxes is None or len(boxes) == 0:
                continue

            names = getattr(result, "names", {}) or {}

            for box in boxes:
                cls_idx = int(box.cls[0].item())
                conf_val = float(box.conf[0].item())
                class_name = names.get(cls_idx, str(cls_idx))

                bbox = {"x1": 0, "y1": 0, "x2": 0, "y2": 0}
                if hasattr(box, "xyxy") and box.xyxy is not None:
                    try:
                        coords = box.xyxy[0].tolist()
                        bbox = {
                            "x1": int(round(coords[0])),
                            "y1": int(round(coords[1])),
                            "x2": int(round(coords[2])),
                            "y2": int(round(coords[3])),
                        }
                    except Exception:
                        pass

                detections.append(
                    {
                        "class_id": cls_idx,
                        "class_name": class_name,
                        "confidence": round(conf_val, 4),
                        "bbox": bbox,
                    }
                )

        return DetectionResult(detections=detections)


# Alias for backward compatibility across existing API dependencies and app lifespan
FoodDetector = YOLOInferenceService
