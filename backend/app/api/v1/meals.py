from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.user import User
from app.schemas.meal import (
    MealCreateRequest,
    MealItemResponse,
    MealListResponse,
    MealRecordListItem,
    MealRecordResponse,
)
from app.schemas.nutrition import NutritionTotals
from app.services.meal_service import create_meal, get_meal_by_id, list_meals

router = APIRouter(prefix="/meals", tags=["Meal Tracking"])


@router.post(
    "",
    response_model=MealRecordResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Buat catatan makan baru",
)
def create_new_meal(
    req: MealCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    meal = create_meal(db, current_user.id, req)
    return MealRecordResponse(
        id=meal.id,
        meal_type=meal.meal_type,
        consumed_at=meal.consumed_at,
        consumed_date=meal.consumed_date,
        items=[
            MealItemResponse(
                id=item.id,
                food_id=item.food_id,
                food_name=item.food.name,
                portion_grams=float(item.portion_grams),
                calories_kcal=float(item.calories_kcal),
                protein_g=float(item.protein_g),
                carbs_g=float(item.carbs_g),
                fat_g=float(item.fat_g),
                source=item.source,
                detection_confidence=(
                    float(item.detection_confidence)
                    if item.detection_confidence is not None
                    else None
                ),
            )
            for item in meal.items
        ],
        totals=NutritionTotals(
            calories_kcal=float(meal.total_calories_kcal),
            protein_g=float(meal.total_protein_g),
            carbs_g=float(meal.total_carbs_g),
            fat_g=float(meal.total_fat_g),
        ),
        created_at=meal.created_at,
    )


@router.get(
    "",
    response_model=MealListResponse,
    status_code=status.HTTP_200_OK,
    summary="Daftar riwayat makan dengan filter tanggal",
)
def get_meals_history(
    date_from: Optional[date] = Query(None, description="Filter tanggal awal (YYYY-MM-DD)"),
    date_to: Optional[date] = Query(None, description="Filter tanggal akhir (YYYY-MM-DD)"),
    page: int = Query(1, ge=1, description="Nomor halaman"),
    page_size: int = Query(20, ge=1, le=100, description="Jumlah item per halaman"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    meals, total = list_meals(
        db,
        user_id=current_user.id,
        date_from=date_from,
        date_to=date_to,
        page=page,
        page_size=page_size,
    )
    items = [
        MealRecordListItem(
            id=m.id,
            meal_type=m.meal_type,
            consumed_at=m.consumed_at,
            consumed_date=m.consumed_date,
            item_count=len(m.items),
            totals=NutritionTotals(
                calories_kcal=float(m.total_calories_kcal),
                protein_g=float(m.total_protein_g),
                carbs_g=float(m.total_carbs_g),
                fat_g=float(m.total_fat_g),
            ),
        )
        for m in meals
    ]
    return MealListResponse(items=items, page=page, page_size=page_size, total=total)


@router.get(
    "/{meal_id}",
    response_model=MealRecordResponse,
    status_code=status.HTTP_200_OK,
    summary="Detail catatan makan",
)
def get_meal_detail(
    meal_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    meal = get_meal_by_id(db, current_user.id, meal_id)
    return MealRecordResponse(
        id=meal.id,
        meal_type=meal.meal_type,
        consumed_at=meal.consumed_at,
        consumed_date=meal.consumed_date,
        items=[
            MealItemResponse(
                id=item.id,
                food_id=item.food_id,
                food_name=item.food.name,
                portion_grams=float(item.portion_grams),
                calories_kcal=float(item.calories_kcal),
                protein_g=float(item.protein_g),
                carbs_g=float(item.carbs_g),
                fat_g=float(item.fat_g),
                source=item.source,
                detection_confidence=(
                    float(item.detection_confidence)
                    if item.detection_confidence is not None
                    else None
                ),
            )
            for item in meal.items
        ],
        totals=NutritionTotals(
            calories_kcal=float(meal.total_calories_kcal),
            protein_g=float(meal.total_protein_g),
            carbs_g=float(meal.total_carbs_g),
            fat_g=float(meal.total_fat_g),
        ),
        created_at=meal.created_at,
    )
