from pydantic import BaseModel, ConfigDict


class TargetBasis(BaseModel):
    bmr_kcal: float
    tdee_kcal: float
    formula: str = "mifflin_st_jeor"


class DailyTargetResponse(BaseModel):
    calories_kcal: int
    protein_g: float
    carbs_g: float
    fat_g: float
    basis: TargetBasis


class NutritionTotals(BaseModel):
    calories_kcal: float
    protein_g: float
    carbs_g: float
    fat_g: float

    model_config = ConfigDict(from_attributes=True)
