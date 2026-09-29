import jwt
from fastapi import Depends, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.core.security import decode_access_token
from app.db.session import get_db
from app.ml.detector import FoodDetector
from app.models.user import User
from app.services.auth_service import is_token_revoked

security = HTTPBearer(auto_error=False)


def get_current_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    if not credentials or not credentials.credentials:
        raise AppError(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="UNAUTHORIZED",
            message="Autentikasi diperlukan untuk mengakses layanan ini.",
        )

    token = credentials.credentials
    try:
        payload = decode_access_token(token)
    except jwt.ExpiredSignatureError:
        raise AppError(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="TOKEN_EXPIRED",
            message="Sesi telah kedaluwarsa. Silakan login kembali.",
        ) from None
    except jwt.PyJWTError:
        raise AppError(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="UNAUTHORIZED",
            message="Token otentikasi tidak valid.",
        ) from None

    jti = payload.get("jti")
    if not jti or is_token_revoked(db, jti):
        raise AppError(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="TOKEN_REVOKED",
            message="Sesi telah dicabut. Silakan login kembali.",
        )

    user_id = payload.get("sub")
    if not user_id:
        raise AppError(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="UNAUTHORIZED",
            message="Token otentikasi tidak valid.",
        )

    user = db.get(User, int(user_id))
    if not user:
        raise AppError(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="UNAUTHORIZED",
            message="Pengguna tidak ditemukan.",
        )

    request.state.current_user = user
    request.state.current_token_jti = jti
    request.state.current_token_exp = payload.get("exp")
    return user


def get_detector(request: Request) -> FoodDetector:
    detector: FoodDetector = getattr(request.app.state, "detector", None)
    if detector is None:
        raise AppError(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            code="MODEL_UNAVAILABLE",
            message="Layanan deteksi makanan saat ini belum tersedia.",
        )
    return detector
