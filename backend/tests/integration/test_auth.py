from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.user import User


def test_health_check(client: TestClient):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["app"] == "NutriView"


def test_register_success(client: TestClient, db: Session):
    payload = {
        "email": "rina@example.com",
        "password": "Password123",
        "full_name": "Rina Kartika",
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "rina@example.com"
    assert data["full_name"] == "Rina Kartika"
    assert "id" in data

    # Verify password is saved as Argon2 hash, not plaintext
    user = db.get(User, data["id"])
    assert user is not None
    assert user.password_hash.startswith("$argon2")


def test_register_duplicate_email(client: TestClient):
    payload = {
        "email": "duplicate@example.com",
        "password": "Password123",
        "full_name": "User Satu",
    }
    r1 = client.post("/api/v1/auth/register", json=payload)
    assert r1.status_code == 201

    r2 = client.post("/api/v1/auth/register", json=payload)
    assert r2.status_code == 409
    assert r2.json()["error"]["code"] == "EMAIL_ALREADY_REGISTERED"


def test_register_invalid_password(client: TestClient):
    payload = {
        "email": "weak@example.com",
        "password": "short",
        "full_name": "Weak Pass",
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


def test_login_success(client: TestClient, test_user: User):
    payload = {
        "email": test_user.email,
        "password": "Password123",
    }
    response = client.post("/api/v1/auth/login", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["expires_in"] > 0


def test_login_invalid_credentials(client: TestClient, test_user: User):
    payload = {
        "email": test_user.email,
        "password": "WrongPassword123",
    }
    response = client.post("/api/v1/auth/login", json=payload)
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "INVALID_CREDENTIALS"
    assert response.json()["error"]["message"] == "Email atau kata sandi salah."


def test_logout_and_revocation(client: TestClient, test_user: User):
    # 1. Login to get token
    login_res = client.post(
        "/api/v1/auth/login",
        json={"email": test_user.email, "password": "Password123"},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Access protected endpoint -> succeeds
    me_res = client.get("/api/v1/users/me", headers=headers)
    assert me_res.status_code == 200

    # 3. Logout -> 204
    logout_res = client.post("/api/v1/auth/logout", headers=headers)
    assert logout_res.status_code == 204

    # 4. Access protected endpoint again -> rejected with 401 TOKEN_REVOKED
    me_res2 = client.get("/api/v1/users/me", headers=headers)
    assert me_res2.status_code == 401
    assert me_res2.json()["error"]["code"] == "TOKEN_REVOKED"


def test_unauthenticated_request(client: TestClient):
    response = client.get("/api/v1/users/me")
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "UNAUTHORIZED"
