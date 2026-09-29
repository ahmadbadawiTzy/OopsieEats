from datetime import date, timezone
from decimal import Decimal
from typing import List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.core.errors import AppError
from app.models.food import Food
from app.models.meal import MealItem, MealRecord
from app.schemas.meal import MealCreateRequest
from app.services.nutrition_service import calculate_portion_nutrition


def create_meal(db: Session, user_id: int, req: MealCreateRequest) -> MealRecord:
    # 1. Fetch and validate all food items
    food_ids = [item.food_id for item in req.items]
    stmt = (
        select(Food)
        .options(joinedload(Food.nutrition))
        .where(Food.id.in_(food_ids), Food.is_active.is_(True))
    )
    foods_by_id = {f.id: f for f in db.scalars(stmt).unique().all()}

    for item in req.items:
        if item.food_id not in foods_by_id:
            raise AppError(
                status_code=404,
                code="FOOD_NOT_FOUND",
                message=f"Makanan dengan ID {item.food_id} tidak ditemukan atau tidak aktif.",
            )

    # 2. Compute snapshots and totals
    total_calories = Decimal("0.00")
    total_protein = Decimal("0.00")
    total_carbs = Decimal("0.00")
    total_fat = Decimal("0.00")

    meal_items: List[MealItem] = []
    for item in req.items:
        food = foods_by_id[item.food_id]
        nutr = food.nutrition
        item_nutr = calculate_portion_nutrition(
            calories_per_100g=nutr.calories_kcal,
            protein_per_100g=nutr.protein_g,
            carbs_per_100g=nutr.carbs_g,
            fat_per_100g=nutr.fat_g,
            portion_grams=item.portion_grams,
        )

        total_calories += item_nutr["calories_kcal"]
        total_protein += item_nutr["protein_g"]
        total_carbs += item_nutr["carbs_g"]
        total_fat += item_nutr["fat_g"]

        meal_item = MealItem(
            food_id=food.id,
            portion_grams=Decimal(str(item.portion_grams)),
            calories_kcal=item_nutr["calories_kcal"],
            protein_g=item_nutr["protein_g"],
            carbs_g=item_nutr["carbs_g"],
            fat_g=item_nutr["fat_g"],
            source=item.source,
            detection_confidence=(
                Decimal(str(item.detection_confidence))
                if item.detection_confidence is not None
                else None
            ),
        )
        meal_items.append(meal_item)

    # Client local date from offset
    consumed_date = req.consumed_at.date()
    # Stored in UTC
    consumed_at_utc = req.consumed_at.astimezone(timezone.utc).replace(tzinfo=None)

    meal_record = MealRecord(
        user_id=user_id,
        meal_type=req.meal_type,
        consumed_at=consumed_at_utc,
        consumed_date=consumed_date,
        total_calories_kcal=total_calories,
        total_protein_g=total_protein,
        total_carbs_g=total_carbs,
        total_fat_g=total_fat,
        items=meal_items,
    )

    db.add(meal_record)
    db.commit()
    db.refresh(meal_record)
    return meal_record


def list_meals(
    db: Session,
    user_id: int,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    page: int = 1,
    page_size: int = 20,
) -> Tuple[List[MealRecord], int]:
    if date_from and date_to and date_from > date_to:
        raise AppError(
            status_code=422,
            code="VALIDATION_ERROR",
            message="date_from tidak boleh lebih besar dari date_to.",
            details=[
                {
                    "field": "date_from",
                    "message": "date_from harus lebih kecil atau sama dengan date_to.",
                }
            ],
        )

    stmt = select(MealRecord).where(MealRecord.user_id == user_id)

    if date_from:
        stmt = stmt.where(MealRecord.consumed_date >= date_from)
    if date_to:
        stmt = stmt.where(MealRecord.consumed_date <= date_to)

    count_stmt = select(func.count()).select_from(stmt.subquery())
    total = db.scalar(count_stmt) or 0

    offset = (page - 1) * page_size
    stmt = (
        stmt.options(joinedload(MealRecord.items))
        .order_by(MealRecord.consumed_at.desc())
        .offset(offset)
        .limit(page_size)
    )
    meals = list(db.scalars(stmt).unique().all())
    return meals, total


def get_meal_by_id(db: Session, user_id: int, meal_id: int) -> MealRecord:
    stmt = (
        select(MealRecord)
        .options(joinedload(MealRecord.items).joinedload(MealItem.food))
        .where(MealRecord.id == meal_id, MealRecord.user_id == user_id)
    )
    meal = db.scalars(stmt).first()
    if not meal:
        raise AppError(
            status_code=404,
            code="MEAL_NOT_FOUND",
            message="Catatan makan tidak ditemukan.",
        )
    return meal
