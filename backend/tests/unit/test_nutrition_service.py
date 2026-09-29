from decimal import Decimal

from app.services.nutrition_service import (
    calculate_daily_target,
    calculate_portion_nutrition,
    round_decimal,
)


def test_mifflin_st_jeor_benchmark():
    """
    Mandatory test case from docs/ai.md §13.1:
    BMR = 1642.5 -> TDEE = 2545.875 ->
    kalori 2546; protein 84.0 g; lemak 70.7 g; karbohidrat 393.4 g.
    """
    result = calculate_daily_target(
        age=25,
        sex="male",
        weight_kg=70.0,
        height_cm=170.0,
        activity_level="moderate",
        goal="maintain_weight",
    )

    assert result["calories_kcal"] == 2546
    assert result["protein_g"] == 84.0
    assert result["fat_g"] == 70.7
    assert result["carbs_g"] == 393.4
    assert result["basis"]["bmr_kcal"] == 1642.5
    assert result["basis"]["tdee_kcal"] == 2545.9
    assert result["basis"]["formula"] == "mifflin_st_jeor"


def test_female_target_calculation():
    # Wanita, 30 tahun, 55 kg, 160 cm, sedentary, lose_weight
    # BMR = 10*55 + 6.25*160 - 5*30 - 161 = 550 + 1000 - 150 - 161 = 1239.0
    # TDEE = 1239 * 1.2 = 1486.8
    # lose_weight: 1486.8 - 500 = 986.8 -> Lower bound for female is 1200!
    # target_cal = 1200
    # protein = 1.6 * 55 = 88.0 g
    # fat = 0.25 * 1200 / 9 = 33.333... -> 33.3 g
    # carbs = (1200 - 88*4 - 300) / 4 = (1200 - 352 - 300) / 4 = 548 / 4 = 137.0 g
    result = calculate_daily_target(
        age=30,
        sex="female",
        weight_kg=55.0,
        height_cm=160.0,
        activity_level="sedentary",
        goal="lose_weight",
    )
    assert result["calories_kcal"] == 1200
    assert result["protein_g"] == 88.0
    assert result["fat_g"] == 33.3
    assert result["carbs_g"] == 137.0
    assert result["basis"]["bmr_kcal"] == 1239.0


def test_male_min_calories_bound():
    # Male calorie floor is 1500
    result = calculate_daily_target(
        age=60,
        sex="male",
        weight_kg=40.0,
        height_cm=140.0,
        activity_level="sedentary",
        goal="lose_weight",
    )
    assert result["calories_kcal"] == 1500


def test_portion_nutrition_calculation():
    # Given nasi putih 250 g:
    # 100g = 130 kcal, 2.4g protein, 28.6g carbs, 0.2g fat
    # 250g = factor 2.5
    # calories = 130 * 2.5 = 325.00
    # protein = 2.4 * 2.5 = 6.00
    # carbs = 28.6 * 2.5 = 71.50
    # fat = 0.2 * 2.5 = 0.50
    result = calculate_portion_nutrition(
        calories_per_100g=130.0,
        protein_per_100g=2.4,
        carbs_per_100g=28.6,
        fat_per_100g=0.2,
        portion_grams=250.0,
    )
    assert result["calories_kcal"] == Decimal("325.00")
    assert result["protein_g"] == Decimal("6.00")
    assert result["carbs_g"] == Decimal("71.50")
    assert result["fat_g"] == Decimal("0.50")


def test_portion_nutrition_half_up_rounding():
    # Test round half up: 1.255 -> 1.26
    val = round_decimal(Decimal("1.255"), 2)
    assert val == Decimal("1.26")
