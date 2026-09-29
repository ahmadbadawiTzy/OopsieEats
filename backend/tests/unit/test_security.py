import jwt
import pytest

from app.core.security import (
    create_access_token,
    decode_access_token,
    hash_password,
    verify_password,
)


def test_password_hash_and_verify():
    password = "SecurePassword123"
    hashed = hash_password(password)
    assert hashed != password
    assert verify_password(password, hashed) is True
    assert verify_password("WrongPassword123", hashed) is False


def test_jwt_token_creation_and_decode():
    user_id = 42
    token, jti, expires_in = create_access_token(user_id)
    assert isinstance(token, str)
    assert len(token) > 20
    assert isinstance(jti, str)
    assert expires_in > 0

    payload = decode_access_token(token)
    assert payload["sub"] == "42"
    assert payload["jti"] == jti
    assert "iat" in payload
    assert "exp" in payload
    assert "email" not in payload  # Ensure sensitive data not leaked in JWT
    assert "password" not in payload


def test_jwt_invalid_token():
    with pytest.raises(jwt.PyJWTError):
        decode_access_token("invalid.token.structure")
