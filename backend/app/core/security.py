import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Dict

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerificationError, VerifyMismatchError

from app.core.config import settings

ph = PasswordHasher()
# Pre-computed dummy hash to mitigate timing attacks when user is not found
DUMMY_HASH = ph.hash("nutriview_dummy_password_for_timing_safety_check")


def hash_password(password: str) -> str:
    return ph.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return ph.verify(hashed_password, plain_password)
    except (VerifyMismatchError, VerificationError):
        return False


def verify_dummy_password(plain_password: str) -> None:
    try:
        ph.verify(DUMMY_HASH, plain_password)
    except Exception:
        pass


def create_access_token(user_id: int) -> tuple[str, str, int]:
    """
    Creates a JWT access token.
    Returns: (token_str, jti_str, expires_in_seconds)
    Claims: sub, jti, iat, exp (docs/ai.md §10)
    """
    now = datetime.now(timezone.utc)
    expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    expire = now + expires_delta
    token_jti = str(uuid.uuid4())

    payload: Dict[str, Any] = {
        "sub": str(user_id),
        "jti": token_jti,
        "iat": int(now.timestamp()),
        "exp": int(expire.timestamp()),
    }

    token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    expires_in = int(expires_delta.total_seconds())
    return token, token_jti, expires_in


def decode_access_token(token: str) -> Dict[str, Any]:
    """
    Decodes and validates a JWT access token.
    Raises jwt.PyJWTError subclasses on invalid/expired token.
    """
    return jwt.decode(
        token,
        settings.JWT_SECRET_KEY,
        algorithms=[settings.JWT_ALGORITHM],
        options={"require": ["sub", "jti", "exp", "iat"]},
    )
