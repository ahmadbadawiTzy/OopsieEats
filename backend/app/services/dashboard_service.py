from datetime import date
from decimal import Decimal
from typing import Any, Dict

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.models.meal import MealRecord
from app.services.nutrition_service import calculate_daily_target, round_decimal
from app.services.profile_service import get_profile_by_user_id


def get_daily_dashboard(
    db: Session,
    user_id: int,
    target_date: date,
) -> Dict[str, Any]:
    # 1. Check profile
    profile = get_profile_by_user_id(db, user_id)
    if not profile:
        raise AppError(
            status_code=400,
            code="PROFILE_INCOMPLETE",
            message="Profil pengguna belum lengkap. Silakan lengkapi profil terlebih dahulu.",
        )

    # 2. Calculate daily target
    target = calculate_daily_target(
        age=profile.age,
        sex=profile.sex,
        weight_kg=profile.weight_kg,
        height_cm=profile.height_cm,
        activity_level=profile.activity_level,
        goal=profile.goal,
    )

    # 3. Aggregate consumed nutrients for the given date
    stmt = select(MealRecord).where(
        MealRecord.user_id == user_id,
        MealRecord.consumed_date == target_date,
    )
    records = list(db.scalars(stmt).all())
    meal_count = len(records)

    c_calories = sum((r.total_calories_kcal for r in records), Decimal("0.00"))
    c_protein = sum((r.total_protein_g for r in records), Decimal("0.00"))
    c_carbs = sum((r.total_carbs_g for r in records), Decimal("0.00"))
    c_fat = sum((r.total_fat_g for r in records), Decimal("0.00"))

    # 4. Progress calculation (percentage rounded to 1 decimal place, not capped)
    t_calories = Decimal(str(target["calories_kcal"]))
    t_protein = Decimal(str(target["protein_g"]))
    t_carbs = Decimal(str(target["carbs_g"]))
    t_fat = Decimal(str(target["fat_g"]))

    def calc_pct(consumed: Decimal, target_val: Decimal) -> float:
        if target_val <= Decimal("0"):
            return 0.0
        pct = (consumed / target_val) * Decimal("100")
        return float(round_decimal(pct, 1))

    return {
        "date": target_date.isoformat(),
        "meal_count": meal_count,
        "target": {
            "calories_kcal": target["calories_kcal"],
            "protein_g": target["protein_g"],
            "carbs_g": target["carbs_g"],
            "fat_g": target["fat_g"],
        },
        "consumed": {
            "calories_kcal": float(round_decimal(c_calories, 2)),
            "protein_g": float(round_decimal(c_protein, 2)),
            "carbs_g": float(round_decimal(c_carbs, 2)),
            "fat_g": float(round_decimal(c_fat, 2)),
        },
        "progress": {
            "calories_kcal": {
                "consumed": float(round_decimal(c_calories, 2)),
                "target": target["calories_kcal"],
                "percentage": calc_pct(c_calories, t_calories),
            },
            "protein_g": {
                "consumed": float(round_decimal(c_protein, 2)),
                "target": target["protein_g"],
                "percentage": calc_pct(c_protein, t_protein),
            },
            "carbs_g": {
                "consumed": float(round_decimal(c_carbs, 2)),
                "target": target["carbs_g"],
                "percentage": calc_pct(c_carbs, t_carbs),
            },
            "fat_g": {
                "consumed": float(round_decimal(c_fat, 2)),
                "target": target["fat_g"],
                "percentage": calc_pct(c_fat, t_fat),
            },
        },
    }
