from typing import List, Union

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_ENV: str = "development"
    LOG_LEVEL: str = "INFO"
    DATABASE_URL: str = "sqlite:///./nutriview_dev.db"
    DATABASE_URL_TEST: str | None = None

    JWT_SECRET_KEY: str = "nutriview_jwt_secret_key_minimum_32_characters_long_for_security"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    CORS_ALLOWED_ORIGINS: Union[List[str], str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    ]
    MODEL_FAMILY: str = "YOLO26n"
    MODEL_PATH: str = "app/ml/weights/best.pt"
    DETECTION_MIN_CONFIDENCE: float = 0.25
    DETECTION_LOW_CONFIDENCE_THRESHOLD: float = 0.50
    MAX_UPLOAD_SIZE_MB: int = 5

    # Validation Constants (PRD §13 & ai.md §8.2)
    MIN_AGE: int = 15
    MAX_AGE: int = 100
    MIN_WEIGHT_KG: float = 20.0
    MAX_WEIGHT_KG: float = 300.0
    MIN_HEIGHT_CM: float = 100.0
    MAX_HEIGHT_CM: float = 250.0
    MIN_PORTION_GRAMS: float = 0.01
    MAX_PORTION_GRAMS: float = 5000.0
    MAX_MEAL_ITEMS: int = 20
    MAX_DETECTED_ITEMS: int = 10

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @field_validator("CORS_ALLOWED_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: str | List[str]) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        elif isinstance(v, list):
            return v
        return ["*"]


settings = Settings()
