from datetime import date, datetime, timedelta, timezone
from typing import List, Literal, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.schemas.nutrition import NutritionTotals

MealType = Literal["breakfast", "lunch", "dinner", "snack"]
MealItemSourceType = Literal["detected", "corrected", "manual"]


class MealItemCreate(BaseModel):
    food_id: int = Field(..., gt=0)
    portion_grams: float = Field(..., gt=0, le=5000.0)
    source: MealItemSourceType
    detection_confidence: Optional[float] = Field(None, ge=0.0, le=1.0)

    model_config = ConfigDict(extra="forbid")

    @field_validator("detection_confidence")
    @classmethod
    def validate_confidence_for_source(cls, v: Optional[float], info) -> Optional[float]:
        source = info.data.get("source")
        if source == "manual" and v is not None:
            raise ValueError("detection_confidence tidak boleh diisi untuk item manual.")
        return v


class MealCreateRequest(BaseModel):
    meal_type: MealType
    consumed_at: datetime
    items: List[MealItemCreate] = Field(..., min_length=1, max_length=20)

    model_config = ConfigDict(extra="forbid")

    @field_validator("consumed_at")
    @classmethod
    def validate_consumed_at(cls, v: datetime) -> datetime:
        if v.tzinfo is None:
            raise ValueError("consumed_at harus memuat informasi zona waktu (offset).")
        now_utc = datetime.now(timezone.utc)
        # Cannot be more than 5 minutes in the future
        if v > now_utc + timedelta(minutes=5):
            raise ValueError("Waktu makan tidak boleh lebih dari 5 menit di masa depan.")
        return v


class MealItemResponse(BaseModel):
    id: int
    food_id: int
    food_name: str
    portion_grams: float
    calories_kcal: float
    protein_g: float
    carbs_g: float
    fat_g: float
    source: str
    detection_confidence: Optional[float] = None

    model_config = ConfigDict(from_attributes=True)


class MealRecordResponse(BaseModel):
    id: int
    meal_type: str
    consumed_at: datetime
    consumed_date: date
    items: List[MealItemResponse]
    totals: NutritionTotals
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MealRecordListItem(BaseModel):
    id: int
    meal_type: str
    consumed_at: datetime
    consumed_date: date
    item_count: int
    totals: NutritionTotals

    model_config = ConfigDict(from_attributes=True)


class MealListResponse(BaseModel):
    items: List[MealRecordListItem]
    page: int
    page_size: int
    total: int
