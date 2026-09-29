import io
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from PIL import Image

from app.ml.detector import DEFAULT_WEIGHTS_PATH, YOLOInferenceService, resolve_model_path
from app.ml.exceptions import (
    CorruptImageError,
    ImageTooLargeError,
    InvalidImageError,
    ModelNotAvailableError,
    UnsupportedImageFormatError,
)


def _create_image_bytes(format_name: str = "JPEG", size=(300, 300), color="green") -> bytes:
    img = Image.new("RGB", size, color=color)
    buf = io.BytesIO()
    img.save(buf, format=format_name)
    return buf.getvalue()


class TestYOLOInferenceService:
    def test_portable_model_path_resolution(self):
        """
        Verify model path resolution is portable and never relies on /content/... or colab paths.
        """
        resolved = resolve_model_path()
        assert isinstance(resolved, Path)
        assert not str(resolved).startswith("/content")
        assert resolved.name == "best.pt"

        # Explicit non-existent path
        custom = resolve_model_path("custom/weights/best.pt")
        assert custom.name == "best.pt"

    def test_model_loads_successfully_when_weights_exist(self):
        """
        Verify model is loaded on initialization if weights exist.
        """
        if not DEFAULT_WEIGHTS_PATH.exists():
            pytest.skip(f"Weight artifact not present at {DEFAULT_WEIGHTS_PATH}")

        service = YOLOInferenceService()
        assert service.is_available is True
        assert service.model is not None
        assert service.load_count == 1
        assert service.model_family == "YOLO26n"

    def test_missing_weights_raises_model_not_available(self):
        """
        When weights are missing, service is not available and detect() raises
        ModelNotAvailableError.
        """
        service = YOLOInferenceService(model_path="non_existent/weights.pt")
        assert service.is_available is False
        assert service.model is None

        valid_img = Image.new("RGB", (100, 100), color="white")
        with pytest.raises(ModelNotAvailableError) as exc_info:
            service.detect(valid_img)
        assert "YOLO26n model is not available" in str(exc_info.value)

    def test_valid_image_formats_processed(self):
        """
        Verify that JPEG, PNG, and WebP images in PIL Image and raw bytes format are processed.
        """
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        service.model_path = "best.pt"
        service.model_family = "YOLO26n"
        service.confidence_threshold = 0.25
        service.max_file_size_bytes = 5 * 1024 * 1024
        service.max_image_pixels = 25_000_000
        service._is_available = True
        service._load_count = 1

        mock_result = MagicMock()
        mock_result.boxes = []
        mock_result.names = {}
        mock_model = MagicMock()
        mock_model.predict.return_value = [mock_result]
        service.model = mock_model

        # 1. PIL Image
        pil_img = Image.new("RGB", (200, 200), color="red")
        res_pil = service.detect(pil_img)
        assert "detections" in res_pil
        assert res_pil["detections"] == []

        # 2. JPEG bytes
        jpeg_bytes = _create_image_bytes("JPEG")
        res_jpeg = service.detect(jpeg_bytes)
        assert "detections" in res_jpeg

        # 3. PNG bytes
        png_bytes = _create_image_bytes("PNG")
        res_png = service.detect(png_bytes)
        assert "detections" in res_png

        # 4. WebP bytes
        webp_bytes = _create_image_bytes("WEBP")
        res_webp = service.detect(webp_bytes)
        assert "detections" in res_webp

    def test_output_structure_and_types(self):
        """
        Verify output structure adheres strictly to:
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
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        service.model_path = "best.pt"
        service.model_family = "YOLO26n"
        service.confidence_threshold = 0.25
        service.max_file_size_bytes = 5 * 1024 * 1024
        service.max_image_pixels = 25_000_000
        service._is_available = True
        service._load_count = 1

        mock_box = MagicMock()
        mock_box.cls = [MagicMock(item=lambda: 1)]
        mock_box.conf = [MagicMock(item=lambda: 0.9123)]
        mock_box.xyxy = [MagicMock(tolist=lambda: [100.2, 80.4, 420.1, 350.0])]

        mock_result = MagicMock()
        mock_result.boxes = [mock_box]
        mock_result.names = {1: "Ayam Goreng"}

        mock_model = MagicMock()
        mock_model.predict.return_value = [mock_result]
        service.model = mock_model

        img = Image.new("RGB", (640, 640), color="yellow")
        result = service.detect(img)

        assert isinstance(result, dict)
        assert "detections" in result
        assert len(result["detections"]) == 1

        det = result["detections"][0]
        assert det["class_id"] == 1
        assert det["class_name"] == "Ayam Goreng"
        assert det["confidence"] == 0.9123
        assert det["bbox"] == {"x1": 100, "y1": 80, "x2": 420, "y2": 350}

        # Bounding box coordinates must be integers and valid coordinates
        assert isinstance(det["bbox"]["x1"], int)
        assert isinstance(det["bbox"]["y1"], int)
        assert isinstance(det["bbox"]["x2"], int)
        assert isinstance(det["bbox"]["y2"], int)

    def test_confidence_scores_within_zero_to_one(self):
        """
        Verify confidence is bounded between 0.0 and 1.0.
        """
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        service.model_path = "best.pt"
        service.model_family = "YOLO26n"
        service.confidence_threshold = 0.25
        service.max_file_size_bytes = 5 * 1024 * 1024
        service.max_image_pixels = 25_000_000
        service._is_available = True
        service._load_count = 1

        boxes = []
        for i, conf in enumerate([0.25, 0.50, 0.85, 0.99, 1.0]):
            b = MagicMock()
            b.cls = [MagicMock(item=lambda c=i: c)]
            b.conf = [MagicMock(item=lambda c=conf: c)]
            b.xyxy = [MagicMock(tolist=lambda: [10.0, 10.0, 50.0, 50.0])]
            boxes.append(b)

        mock_result = MagicMock()
        mock_result.boxes = boxes
        mock_result.names = {i: f"Class_{i}" for i in range(len(boxes))}
        mock_model = MagicMock()
        mock_model.predict.return_value = [mock_result]
        service.model = mock_model

        img = Image.new("RGB", (300, 300))
        result = service.detect(img)

        for det in result["detections"]:
            assert 0.0 <= det["confidence"] <= 1.0

    def test_bounding_box_validity(self):
        """
        Verify x1 <= x2 and y1 <= y2 for all detected bounding boxes.
        """
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        service.model_path = "best.pt"
        service.model_family = "YOLO26n"
        service.confidence_threshold = 0.25
        service.max_file_size_bytes = 5 * 1024 * 1024
        service.max_image_pixels = 25_000_000
        service._is_available = True
        service._load_count = 1

        mock_box = MagicMock()
        mock_box.cls = [MagicMock(item=lambda: 13)]
        mock_box.conf = [MagicMock(item=lambda: 0.95)]
        mock_box.xyxy = [MagicMock(tolist=lambda: [50.0, 75.0, 320.0, 400.0])]

        mock_result = MagicMock()
        mock_result.boxes = [mock_box]
        mock_result.names = {13: "Nasi Putih"}
        mock_model = MagicMock()
        mock_model.predict.return_value = [mock_result]
        service.model = mock_model

        img = Image.new("RGB", (640, 640))
        result = service.detect(img)

        for det in result["detections"]:
            bbox = det["bbox"]
            assert bbox["x1"] <= bbox["x2"]
            assert bbox["y1"] <= bbox["y2"]
            assert bbox["x1"] >= 0
            assert bbox["y1"] >= 0

    def test_invalid_and_corrupt_images_rejected(self):
        """
        Verify rejection of corrupt images, unsupported image formats, oversized images, and None.
        """
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        service.model_path = "best.pt"
        service.model_family = "YOLO26n"
        service.confidence_threshold = 0.25
        service.max_file_size_bytes = 1024 * 1024  # 1 MB for testing
        service.max_image_pixels = 100_000  # small limit for testing decompression bomb
        service._is_available = True
        service._load_count = 1
        service.model = MagicMock()

        # 1. None
        with pytest.raises(InvalidImageError):
            service.detect(None)

        # 2. Empty bytes
        with pytest.raises(InvalidImageError):
            service.detect(b"")

        # 3. Corrupt bytes
        with pytest.raises(CorruptImageError):
            service.detect(b"corrupted_non_image_header_and_data")

        # 4. Unsupported format (e.g., GIF)
        gif_buf = io.BytesIO()
        Image.new("RGB", (50, 50)).save(gif_buf, format="GIF")
        with pytest.raises(UnsupportedImageFormatError):
            service.detect(gif_buf.getvalue())

        # 5. File size too large
        oversized_bytes = b"x" * (1024 * 1024 + 10)
        with pytest.raises(ImageTooLargeError):
            service.detect(oversized_bytes)

        # 6. Pixel dimension decompression bomb
        large_dim_img = Image.new("RGB", (1000, 1000))  # 1,000,000 pixels > 100,000
        with pytest.raises(ImageTooLargeError):
            service.detect(large_dim_img)

    def test_model_not_reloaded_on_every_inference(self):
        """
        Verify model is loaded exactly once upon initialization and reused for every inference.
        """
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        service.model_path = "best.pt"
        service.model_family = "YOLO26n"
        service.confidence_threshold = 0.25
        service.max_file_size_bytes = 5 * 1024 * 1024
        service.max_image_pixels = 25_000_000
        service._is_available = True
        service._load_count = 1

        mock_result = MagicMock()
        mock_result.boxes = []
        mock_result.names = {}
        mock_model = MagicMock()
        mock_model.predict.return_value = [mock_result]
        service.model = mock_model

        test_img = Image.new("RGB", (100, 100), color="blue")

        # Execute 5 inferences
        for _ in range(5):
            service.detect(test_img)

        # Verify model was NOT reloaded
        assert service.load_count == 1
        assert service.model is mock_model
        assert mock_model.predict.call_count == 5

    def test_configurable_confidence_threshold(self):
        """
        Verify confidence threshold is configurable via constructor and per detect() call.
        """
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        service.model_path = "best.pt"
        service.model_family = "YOLO26n"
        service.confidence_threshold = 0.35
        service.max_file_size_bytes = 5 * 1024 * 1024
        service.max_image_pixels = 25_000_000
        service._is_available = True
        service._load_count = 1

        mock_model = MagicMock()
        mock_model.predict.return_value = [MagicMock(boxes=[])]
        service.model = mock_model

        img = Image.new("RGB", (100, 100))

        # Default configured confidence
        service.detect(img)
        assert mock_model.predict.call_args[1]["conf"] == 0.35

        # Override per detect call
        service.detect(img, confidence_threshold=0.60)
        assert mock_model.predict.call_args[1]["conf"] == 0.60

    def test_strict_negative_boundaries(self):
        """
        Verify the ML service strictly does NOT contain or perform nutrition calculation,
        database queries, or portion estimation.
        """
        service = YOLOInferenceService.__new__(YOLOInferenceService)
        # Methods that MUST NOT exist on the ML service
        forbidden_attrs = [
            "calculate_calories",
            "calculate_nutrition",
            "calculate_daily_target",
            "estimate_portion",
            "save_meal",
            "get_db",
            "db_session",
            "user",
        ]
        for attr in forbidden_attrs:
            assert not hasattr(service, attr), f"YOLOInferenceService must not have {attr}"
