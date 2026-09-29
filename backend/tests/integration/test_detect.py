import io
from unittest.mock import MagicMock

from fastapi.testclient import TestClient
from PIL import Image

from app.api.deps import get_detector
from app.main import app
from app.ml.detector import FoodDetector


def _create_test_image(format_name: str = "JPEG", size=(100, 100)) -> io.BytesIO:
    img = Image.new("RGB", size, color="blue")
    buf = io.BytesIO()
    img.save(buf, format=format_name)
    buf.seek(0)
    return buf


def test_detect_food_mocked_yolo26n(client: TestClient, auth_headers: dict):
    # Mock detector
    mock_detector = MagicMock(spec=FoodDetector)
    mock_detector.is_available = True
    # Simulate raw YOLO26n detection: 2 nasi_putih (duplicate), 1 ayam_goreng, 1 unknown_class
    mock_detector.detect.return_value = [
        {"class_name": "nasi_putih", "confidence": 0.85},
        {"class_name": "nasi_putih", "confidence": 0.95},  # duplicate, higher confidence
        {"class_name": "ayam_goreng", "confidence": 0.45},  # low confidence (< 0.50)
        {"class_name": "pizza_hut_unknown", "confidence": 0.90},  # unmapped class
    ]

    app.dependency_overrides[get_detector] = lambda: mock_detector

    try:
        img_buf = _create_test_image("JPEG")
        response = client.post(
            "/api/v1/foods/detect",
            files={"image": ("plate.jpg", img_buf, "image/jpeg")},
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert "detections" in data
        assert len(data["detections"]) == 2  # nasi_putih and ayam_goreng

        # Highest confidence nasi_putih kept
        nasi = next(d for d in data["detections"] if d["food_name"] == "Nasi putih")
        assert nasi["confidence"] == 0.95
        assert nasi["low_confidence"] is False

        # ayam_goreng has low_confidence = True (0.45 < 0.50)
        ayam = next(d for d in data["detections"] if d["food_name"] == "Ayam goreng")
        assert ayam["confidence"] == 0.45
        assert ayam["low_confidence"] is True
    finally:
        app.dependency_overrides.pop(get_detector, None)


def test_detect_food_model_unavailable_returns_503(client: TestClient, auth_headers: dict):
    mock_detector = MagicMock(spec=FoodDetector)
    mock_detector.is_available = False

    app.dependency_overrides[get_detector] = lambda: mock_detector

    try:
        img_buf = _create_test_image("JPEG")
        response = client.post(
            "/api/v1/foods/detect",
            files={"image": ("food.jpg", img_buf, "image/jpeg")},
            headers=auth_headers,
        )
        assert response.status_code == 503
        assert response.json()["error"]["code"] == "MODEL_UNAVAILABLE"
    finally:
        app.dependency_overrides.pop(get_detector, None)


def test_detect_food_invalid_file_extension(client: TestClient, auth_headers: dict):
    buf = io.BytesIO(b"fake data")
    response = client.post(
        "/api/v1/foods/detect",
        files={"image": ("file.pdf", buf, "application/pdf")},
        headers=auth_headers,
    )
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "UNSUPPORTED_IMAGE_TYPE"
