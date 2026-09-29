from decimal import ROUND_HALF_UP, Decimal
from typing import Any, Dict

ACTIVITY_FACTORS: Dict[str, Decimal] = {
    "sedentary": Decimal("1.2"),
    "light": Decimal("1.375"),
    "moderate": Decimal("1.55"),
    "active": Decimal("1.725"),
    "very_active": Decimal("1.9"),
}

PROTEIN_PER_KG: Dict[str, Decimal] = {
    "lose_weight": Decimal("1.6"),
    "maintain_weight": Decimal("1.2"),
    "gain_weight": Decimal("1.6"),
}

GOAL_CALORIE_DELTA: Dict[str, Decimal] = {
    "lose_weight": Decimal("-500"),
    "maintain_weight": Decimal("0"),
    "gain_weight": Decimal("300"),
}

MIN_CALORIES: Dict[str, Decimal] = {
    "male": Decimal("1500"),
    "female": Decimal("1200"),
}


def round_decimal(value: Decimal, places: int) -> Decimal:
    q = Decimal(10) ** -places
    return value.quantize(q, rounding=ROUND_HALF_UP)


def calculate_daily_target(
    age: int,
    sex: str,
    weight_kg: float | Decimal,
    height_cm: float | Decimal,
    activity_level: str,
    goal: str,
) -> Dict[str, Any]:
    """
    Calculates daily caloric and macronutrient targets deterministically
    following docs/ai.md §13.1 (Mifflin-St Jeor formula).
    """
    d_age = Decimal(str(age))
    d_weight = Decimal(str(weight_kg))
    d_height = Decimal(str(height_cm))

    # Step 1: BMR (Mifflin-St Jeor)
    # male:   BMR = 10 * berat_kg + 6.25 * tinggi_cm - 5 * usia + 5
    # female: BMR = 10 * berat_kg + 6.25 * tinggi_cm - 5 * usia - 161
    if sex == "male":
        bmr = (
            (Decimal("10") * d_weight)
            + (Decimal("6.25") * d_height)
            - (Decimal("5") * d_age)
            + Decimal("5")
        )
    else:
        bmr = (
            (Decimal("10") * d_weight)
            + (Decimal("6.25") * d_height)
            - (Decimal("5") * d_age)
            - Decimal("161")
        )

    # Step 2: TDEE = BMR * activity_factor
    factor = ACTIVITY_FACTORS[activity_level]
    tdee = bmr * factor

    # Step 3: Target Calories = TDEE + delta, subject to lower bounds
    calorie_target = tdee + GOAL_CALORIE_DELTA[goal]
    min_cal = MIN_CALORIES[sex]
    if calorie_target < min_cal:
        calorie_target = min_cal

    # Step 4: Macronutrients
    # protein_g = protein_per_kg * berat_kg
    # fat_g     = 0.25 * kalori_target / 9
    # carbs_g   = (kalori_target - protein_g * 4 - fat_g * 9) / 4 (min 0)
    protein_rate = PROTEIN_PER_KG[goal]
    protein = protein_rate * d_weight
    fat = (Decimal("0.25") * calorie_target) / Decimal("9")
    carbs = (calorie_target - (protein * Decimal("4")) - (fat * Decimal("9"))) / Decimal("4")
    if carbs < Decimal("0"):
        carbs = Decimal("0")

    # Output rounding: calories -> int, macros -> 1 decimal, basis -> 1 decimal
    return {
        "calories_kcal": int(round_decimal(calorie_target, 0)),
        "protein_g": float(round_decimal(protein, 1)),
        "carbs_g": float(round_decimal(carbs, 1)),
        "fat_g": float(round_decimal(fat, 1)),
        "basis": {
            "bmr_kcal": float(round_decimal(bmr, 1)),
            "tdee_kcal": float(round_decimal(tdee, 1)),
            "formula": "mifflin_st_jeor",
        },
    }


def calculate_portion_nutrition(
    calories_per_100g: float | Decimal,
    protein_per_100g: float | Decimal,
    carbs_per_100g: float | Decimal,
    fat_per_100g: float | Decimal,
    portion_grams: float | Decimal,
) -> Dict[str, Decimal]:
    """
    Calculates nutrition for a consumed portion from per 100g values:
    nutrisi_dikonsumsi = nutrisi_per_100g * portion_grams / 100
    Each nutrient rounded to 2 decimal places with ROUND_HALF_UP (docs/ai.md §13.2).
    """
    p_grams = Decimal(str(portion_grams))
    factor = p_grams / Decimal("100")

    c = Decimal(str(calories_per_100g)) * factor
    pr = Decimal(str(protein_per_100g)) * factor
    cb = Decimal(str(carbs_per_100g)) * factor
    f = Decimal(str(fat_per_100g)) * factor

    return {
        "calories_kcal": round_decimal(c, 2),
        "protein_g": round_decimal(pr, 2),
        "carbs_g": round_decimal(cb, 2),
        "fat_g": round_decimal(f, 2),
    }
