from typing import List

from pydantic import BaseModel, ConfigDict


class FoodItemResponse(BaseModel):
    id: int
    name: str
    calories_kcal_per_100g: float
    protein_g_per_100g: float
    carbs_g_per_100g: float
    fat_g_per_100g: float

    model_config = ConfigDict(from_attributes=True)


class FoodDetailResponse(FoodItemResponse):
    source: str


class FoodListResponse(BaseModel):
    items: List[FoodItemResponse]
    page: int
    page_size: int
    total: int


class DetectionItem(BaseModel):
    food_id: int
    food_name: str
    confidence: float
    low_confidence: bool


class DetectFoodResponse(BaseModel):
    detections: List[DetectionItem]
    low_confidence_threshold: float
