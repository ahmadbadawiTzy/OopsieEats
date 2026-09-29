import os
from typing import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.security import create_access_token, hash_password
from app.db.base import Base
from app.db.seed.seed_data import seed_foods_from_csv
from app.db.session import get_db
from app.main import app
from app.models.user import User

# Use an in-memory SQLite database for test isolation
TEST_DATABASE_URL = "sqlite:///:memory:"

test_engine = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


@pytest.fixture(scope="session", autouse=True)
def setup_test_db():
    Base.metadata.create_all(bind=test_engine)
    csv_path = os.path.join(os.path.dirname(__file__), "..", "app", "db", "seed", "foods.csv")
    with TestingSessionLocal() as session:
        seed_foods_from_csv(session, csv_path)
    yield
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture
def db() -> Generator[Session, None, None]:
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        with TestingSessionLocal() as clean_session:
            clean_session.execute(text("DELETE FROM meal_items"))
            clean_session.execute(text("DELETE FROM meal_records"))
            clean_session.execute(text("DELETE FROM profiles"))
            clean_session.execute(text("DELETE FROM revoked_tokens"))
            clean_session.execute(text("DELETE FROM users"))
            clean_session.commit()


@pytest.fixture
def client(db: Session) -> Generator[TestClient, None, None]:
    def override_get_db():
        yield db

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture
def test_user(db: Session) -> User:
    user = User(
        email="testuser@nutriview.com",
        password_hash=hash_password("Password123"),
        full_name="User Pengujian",
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def auth_headers(test_user: User) -> dict[str, str]:
    token, _, _ = create_access_token(test_user.id)
    return {"Authorization": f"Bearer {token}"}
