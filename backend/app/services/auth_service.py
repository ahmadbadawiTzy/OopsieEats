from datetime import datetime, timezone
from typing import Optional, Tuple

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.core.security import (
    create_access_token,
    hash_password,
    verify_dummy_password,
    verify_password,
)
from app.models.revoked_token import RevokedToken
from app.models.user import User
from app.schemas.auth import LoginRequest, RegisterRequest


def get_user_by_email(db: Session, email: str) -> Optional[User]:
    stmt = select(User).where(User.email == email.strip().lower())
    return db.scalars(stmt).first()


def register_user(db: Session, req: RegisterRequest) -> User:
    normalized_email = req.email.strip().lower()
    existing = get_user_by_email(db, normalized_email)
    if existing:
        raise AppError(
            status_code=409,
            code="EMAIL_ALREADY_REGISTERED",
            message="Email ini sudah terdaftar.",
        )

    user = User(
        email=normalized_email,
        password_hash=hash_password(req.password),
        full_name=req.full_name.strip(),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(db: Session, req: LoginRequest) -> Tuple[User, str, int]:
    user = get_user_by_email(db, req.email)
    if not user:
        verify_dummy_password(req.password)
        raise AppError(
            status_code=401,
            code="INVALID_CREDENTIALS",
            message="Email atau kata sandi salah.",
        )

    if not verify_password(req.password, user.password_hash):
        raise AppError(
            status_code=401,
            code="INVALID_CREDENTIALS",
            message="Email atau kata sandi salah.",
        )

    token, jti, expires_in = create_access_token(user.id)
    return user, token, expires_in


def revoke_token(db: Session, jti: str, exp_timestamp: int) -> None:
    now_utc = datetime.now(timezone.utc)
    # Opportunistically clean expired tokens
    db.execute(delete(RevokedToken).where(RevokedToken.expires_at < now_utc))

    expires_at = datetime.fromtimestamp(exp_timestamp, tz=timezone.utc)
    revoked = RevokedToken(jti=jti, expires_at=expires_at)
    db.add(revoked)
    db.commit()


def is_token_revoked(db: Session, jti: str) -> bool:
    stmt = select(RevokedToken).where(RevokedToken.jti == jti)
    return db.scalars(stmt).first() is not None
