import io

import pytest
from PIL import Image

from app.api.v1.foods import ALLOWED_EXTENSIONS, ALLOWED_MIME_TYPES, MAX_IMAGE_PIXELS


def test_allowed_extensions_and_mime_types():
    assert ".jpg" in ALLOWED_EXTENSIONS
    assert ".jpeg" in ALLOWED_EXTENSIONS
    assert ".png" in ALLOWED_EXTENSIONS
    assert ".webp" in ALLOWED_EXTENSIONS
    assert ".gif" not in ALLOWED_EXTENSIONS
    assert ".bmp" not in ALLOWED_EXTENSIONS

    assert "image/jpeg" in ALLOWED_MIME_TYPES
    assert "image/png" in ALLOWED_MIME_TYPES
    assert "image/webp" in ALLOWED_MIME_TYPES
    assert "image/gif" not in ALLOWED_MIME_TYPES


def test_pillow_image_verification_valid():
    img = Image.new("RGB", (100, 100), color="red")
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    buf.seek(0)

    opened = Image.open(buf)
    opened.verify()
    assert opened.format == "JPEG"


def test_pillow_image_verification_corrupt():
    corrupt_data = b"NOT_A_REAL_IMAGE_DATA_JUST_BYTES"
    buf = io.BytesIO(corrupt_data)

    with pytest.raises(Image.UnidentifiedImageError):
        opened = Image.open(buf)
        opened.verify()


def test_decompression_bomb_limit():
    assert MAX_IMAGE_PIXELS == 25_000_000
