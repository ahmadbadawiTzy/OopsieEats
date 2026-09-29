"""
NutriView - Machine Learning & Inference Service Exceptions.
"""


class MLInferenceError(Exception):
    """Base exception for all ML inference and processing errors."""

    pass


class ModelNotAvailableError(MLInferenceError, RuntimeError):
    """Raised when the YOLO26n model weights are not loaded or unavailable."""

    pass


class InvalidImageError(MLInferenceError, ValueError):
    """Raised when the provided image is invalid or cannot be decoded."""

    pass


class ImageTooLargeError(InvalidImageError):
    """Raised when the image file size or resolution exceeds allowable limits."""

    pass


class UnsupportedImageFormatError(InvalidImageError):
    """Raised when the image format is not supported (only JPEG, PNG, WebP are allowed)."""

    pass


class CorruptImageError(InvalidImageError):
    """Raised when image bytes/content is corrupt or fails Pillow verification."""

    pass


class InferenceFailureError(MLInferenceError, RuntimeError):
    """Raised when YOLO prediction/inference execution encounters a runtime failure."""

    pass
