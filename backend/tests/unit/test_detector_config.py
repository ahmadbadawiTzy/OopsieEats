import os
from unittest.mock import MagicMock

import pytest
from PIL import Image

from app.core.config import settings
from app.ml.detector import FoodDetector


def test_yolo26n_settings_and_detector_configuration():
    """
    Verify that:
    1. settings.MODEL_FAMILY is configured as 'YOLO26n'.
    2. FoodDetector default model_family resolves to 'YOLO26n'.
    3. Production weight artifact path is 'app/ml/weights/best.pt'.
    """
    assert settings.MODEL_FAMILY == "YOLO26n"
    assert settings.MODEL_PATH == "app/ml/weights/best.pt"

    detector = FoodDetector()
    assert detector.model_family == "YOLO26n"
    assert detector.model_path == "app/ml/weights/best.pt"


def test_yolo26n_missing_weights_behavior():
    """
    When the weight artifact (best.pt) does not exist:
    - is_available must be False.
    - calling detect() must raise RuntimeError identifying YOLO26n as unavailable.
    """
    non_existent_path = "app/ml/weights/non_existent_weights_xyz.pt"
    assert not os.path.exists(non_existent_path)

    detector = FoodDetector(model_path=non_existent_path)
    assert detector.is_available is False
    assert detector.model is None

    test_image = Image.new("RGB", (100, 100), color="red")
    with pytest.raises(RuntimeError) as exc_info:
        detector.detect(test_image)

    assert "YOLO26n model is not available" in str(exc_info.value)


def test_yolo26n_detection_raw_contract():
    """
    Verify the detection contract: FoodDetector produces structured detection result
    containing detections with 'class_id', 'class_name', 'confidence', and 'bbox'.
    """
    detector = FoodDetector.__new__(FoodDetector)
    detector.model_path = "dummy.pt"
    detector.model_family = "YOLO26n"
    detector.confidence_threshold = 0.25
    detector.max_file_size_bytes = 5 * 1024 * 1024
    detector.max_image_pixels = 25_000_000
    detector._is_available = True

    # Mock ultralytics predict result
    mock_box_1 = MagicMock()
    mock_box_1.cls = [MagicMock(item=lambda: 0)]
    mock_box_1.conf = [MagicMock(item=lambda: 0.92)]
    mock_box_1.xyxy = [MagicMock(tolist=lambda: [100.0, 80.0, 420.0, 350.0])]

    mock_box_2 = MagicMock()
    mock_box_2.cls = [MagicMock(item=lambda: 2)]
    mock_box_2.conf = [MagicMock(item=lambda: 0.78)]
    mock_box_2.xyxy = [MagicMock(tolist=lambda: [150.0, 90.0, 380.0, 290.0])]

    mock_result = MagicMock()
    mock_result.boxes = [mock_box_1, mock_box_2]
    mock_result.names = {0: "Nasi Putih", 2: "Ayam Goreng"}

    mock_model = MagicMock()
    mock_model.predict.return_value = [mock_result]
    detector.model = mock_model

    test_image = Image.new("RGB", (640, 640), color="blue")
    result = detector.detect(test_image)

    assert "detections" in result
    detections = result["detections"]
    assert len(detections) == 2
    for det in detections:
        assert set(det.keys()) == {"class_id", "class_name", "confidence", "bbox"}
        assert isinstance(det["class_id"], int)
        assert isinstance(det["class_name"], str)
        assert isinstance(det["confidence"], float)
        assert set(det["bbox"].keys()) == {"x1", "y1", "x2", "y2"}

    assert detections[0]["class_id"] == 0
    assert detections[0]["class_name"] == "Nasi Putih"
    assert detections[0]["confidence"] == 0.92
    assert detections[0]["bbox"] == {"x1": 100, "y1": 80, "x2": 420, "y2": 350}

    assert detections[1]["class_id"] == 2
    assert detections[1]["class_name"] == "Ayam Goreng"
    assert detections[1]["confidence"] == 0.78
    assert detections[1]["bbox"] == {"x1": 150, "y1": 90, "x2": 380, "y2": 290}


def test_ultralytics_yolo26n_architecture_support():
    """
    Verify that the installed Ultralytics version natively supports YOLO26n architecture.
    """
    from ultralytics import YOLO

    # Instantiating from yolo26n.yaml verifies architecture syntax and layer definitions
    model = YOLO("yolo26n.yaml")
    assert model is not None
    assert hasattr(model, "model")
    # Verify it has detection layers
    assert hasattr(model.model, "yaml")
