from fastapi.testclient import TestClient


def test_target_without_profile_returns_400(client: TestClient, auth_headers: dict):
    response = client.get("/api/v1/nutrition/target", headers=auth_headers)
    assert response.status_code == 400
    assert response.json()["error"]["code"] == "PROFILE_INCOMPLETE"


def test_upsert_profile_and_get_target(client: TestClient, auth_headers: dict):
    # Benchmark input: pria, 25 tahun, 70 kg, 170 cm, moderate, maintain_weight
    profile_payload = {
        "age": 25,
        "sex": "male",
        "weight_kg": 70.0,
        "height_cm": 170.0,
        "activity_level": "moderate",
        "goal": "maintain_weight",
    }
    put_res = client.put("/api/v1/users/me/profile", json=profile_payload, headers=auth_headers)
    assert put_res.status_code == 200
    data = put_res.json()
    assert data["age"] == 25
    assert data["weight_kg"] == 70.0

    # GET /users/me includes profile
    me_res = client.get("/api/v1/users/me", headers=auth_headers)
    assert me_res.status_code == 200
    assert me_res.json()["profile"] is not None
    assert me_res.json()["profile"]["goal"] == "maintain_weight"

    # GET /nutrition/target returns benchmark values
    tgt_res = client.get("/api/v1/nutrition/target", headers=auth_headers)
    assert tgt_res.status_code == 200
    tgt = tgt_res.json()
    assert tgt["calories_kcal"] == 2546
    assert tgt["protein_g"] == 84.0
    assert tgt["fat_g"] == 70.7
    assert tgt["carbs_g"] == 393.4
    assert tgt["basis"]["bmr_kcal"] == 1642.5
    assert tgt["basis"]["tdee_kcal"] == 2545.9


def test_profile_validation_errors(client: TestClient, auth_headers: dict):
    # Age out of range (< 15)
    r1 = client.put(
        "/api/v1/users/me/profile",
        json={
            "age": 10,
            "sex": "male",
            "weight_kg": 70.0,
            "height_cm": 170.0,
            "activity_level": "moderate",
            "goal": "maintain_weight",
        },
        headers=auth_headers,
    )
    assert r1.status_code == 422
    assert r1.json()["error"]["code"] == "VALIDATION_ERROR"

    # Weight out of range (> 300)
    r2 = client.put(
        "/api/v1/users/me/profile",
        json={
            "age": 25,
            "sex": "male",
            "weight_kg": 350.0,
            "height_cm": 170.0,
            "activity_level": "moderate",
            "goal": "maintain_weight",
        },
        headers=auth_headers,
    )
    assert r2.status_code == 422
