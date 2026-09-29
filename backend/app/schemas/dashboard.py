from pydantic import BaseModel, ConfigDict

from app.schemas.nutrition import NutritionTotals


class NutrientProgress(BaseModel):
    consumed: float
    target: float
    percentage: float


class DashboardProgress(BaseModel):
    calories_kcal: NutrientProgress
    protein_g: NutrientProgress
    carbs_g: NutrientProgress
    fat_g: NutrientProgress


class DailyDashboardResponse(BaseModel):
    date: str
    meal_count: int
    target: NutritionTotals
    consumed: NutritionTotals
    progress: DashboardProgress

    model_config = ConfigDict(from_attributes=True)
