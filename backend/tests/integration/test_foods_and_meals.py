from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.security import create_access_token, hash_password
from app.models.user import User


def test_foods_listing_and_search(client: TestClient, auth_headers: dict):
    # List all foods
    res = client.get("/api/v1/foods", headers=auth_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["total"] >= 15
    assert len(data["items"]) > 0

    # Search for "nasi"
    search_res = client.get("/api/v1/foods?q=nasi", headers=auth_headers)
    assert search_res.status_code == 200
    search_data = search_res.json()
    assert search_data["total"] >= 2  # Nasi putih, Nasi goreng
    for item in search_data["items"]:
        assert "nasi" in item["name"].lower()


def test_food_detail(client: TestClient, auth_headers: dict):
    res = client.get("/api/v1/foods/1", headers=auth_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["id"] == 1
    assert "name" in data
    assert "source" in data
    assert "calories_kcal_per_100g" in data

    # Non-existent food -> 404
    res_404 = client.get("/api/v1/foods/99999", headers=auth_headers)
    assert res_404.status_code == 404
    assert res_404.json()["error"]["code"] == "FOOD_NOT_FOUND"


def test_meal_creation_and_snapshot(client: TestClient, auth_headers: dict):
    # Food 1: Nasi putih (130 kcal, 2.4g P, 28.6g C, 0.2g L per 100g)
    # Portion: 250g -> 325 kcal, 6.0g P, 71.5g C, 0.5g L
    # Food 3: Ayam goreng (246 kcal, 25.0g P, 0.0g C, 16.0g L per 100g)
    # Portion: 100g -> 246 kcal, 25.0g P, 0.0g C, 16.0g L
    # Expected total: 325 + 246 = 571 kcal
    # Expected protein: 6.0 + 25.0 = 31.0g
    # Expected carbs: 71.5 + 0.0 = 71.5g
    # Expected fat: 0.5 + 16.0 = 16.5g
    payload = {
        "meal_type": "lunch",
        "consumed_at": "2026-09-29T12:30:00+07:00",
        "items": [
            {
                "food_id": 1,
                "portion_grams": 250.0,
                "source": "detected",
                "detection_confidence": 0.92,
            },
            {
                "food_id": 3,
                "portion_grams": 100.0,
                "source": "manual",
            },
        ],
    }
    res = client.post("/api/v1/meals", json=payload, headers=auth_headers)
    assert res.status_code == 201
    meal = res.json()

    assert meal["meal_type"] == "lunch"
    assert meal["consumed_date"] == "2026-09-29"
    assert len(meal["items"]) == 2

    # Check totals match sum of items
    assert meal["totals"]["calories_kcal"] == 571.0
    assert meal["totals"]["protein_g"] == 31.0
    assert meal["totals"]["carbs_g"] == 71.5
    assert meal["totals"]["fat_g"] == 16.5

    # Check item snapshots
    item1 = meal["items"][0]
    assert item1["calories_kcal"] == 325.0
    assert item1["source"] == "detected"
    assert item1["detection_confidence"] == 0.92


def test_meal_validation_portion_and_items(client: TestClient, auth_headers: dict):
    # Portion <= 0 rejected
    r1 = client.post(
        "/api/v1/meals",
        json={
            "meal_type": "lunch",
            "consumed_at": "2026-09-29T12:00:00+07:00",
            "items": [{"food_id": 1, "portion_grams": 0, "source": "manual"}],
        },
        headers=auth_headers,
    )
    assert r1.status_code == 422

    # Empty items list rejected
    r2 = client.post(
        "/api/v1/meals",
        json={
            "meal_type": "lunch",
            "consumed_at": "2026-09-29T12:00:00+07:00",
            "items": [],
        },
        headers=auth_headers,
    )
    assert r2.status_code == 422


def test_meal_isolation_between_users(client: TestClient, db: Session, auth_headers: dict):
    # 1. User A creates a meal
    res = client.post(
        "/api/v1/meals",
        json={
            "meal_type": "dinner",
            "consumed_at": "2026-09-29T19:00:00+07:00",
            "items": [{"food_id": 1, "portion_grams": 100, "source": "manual"}],
        },
        headers=auth_headers,
    )
    assert res.status_code == 201
    meal_id = res.json()["id"]

    # 2. User B tries to view User A's meal
    user_b = User(
        email="other@nutriview.com",
        password_hash=hash_password("Password123"),
        full_name="User Lain",
    )
    db.add(user_b)
    db.commit()
    db.refresh(user_b)

    token_b, _, _ = create_access_token(user_b.id)
    headers_b = {"Authorization": f"Bearer {token_b}"}

    res_b = client.get(f"/api/v1/meals/{meal_id}", headers=headers_b)
    # Must return 404 MEAL_NOT_FOUND (not 403) to prevent enumeration (docs/ai.md §10)
    assert res_b.status_code == 404
    assert res_b.json()["error"]["code"] == "MEAL_NOT_FOUND"


def test_daily_dashboard_aggregation(client: TestClient, auth_headers: dict):
    # 1. Set profile so dashboard can calculate progress
    client.put(
        "/api/v1/users/me/profile",
        json={
            "age": 25,
            "sex": "male",
            "weight_kg": 70.0,
            "height_cm": 170.0,
            "activity_level": "moderate",
            "goal": "maintain_weight",
        },
        headers=auth_headers,
    )

    # 2. Log a meal for 2026-09-29
    meal_payload = {
        "meal_type": "lunch",
        "consumed_at": "2026-09-29T12:00:00Z",
        "items": [{"food_id": 1, "portion_grams": 100, "source": "manual"}],
    }
    meal_res = client.post("/api/v1/meals", json=meal_payload, headers=auth_headers)
    assert meal_res.status_code == 201

    # 3. Query dashboard for 2026-09-29
    dash_res = client.get("/api/v1/dashboard/daily?date=2026-09-29", headers=auth_headers)
    assert dash_res.status_code == 200
    data = dash_res.json()
    assert data["date"] == "2026-09-29"
    assert "target" in data
    assert "consumed" in data
    assert "progress" in data
    assert data["target"]["calories_kcal"] == 2546
    assert data["consumed"]["calories_kcal"] > 0
    assert data["meal_count"] >= 1
