from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse, UserResponse
from app.schemas.dashboard import DailyDashboardResponse, DashboardProgress, NutrientProgress
from app.schemas.error import ErrorDetail, ErrorInfo, ErrorResponse
from app.schemas.food import (
    DetectFoodResponse,
    DetectionItem,
    FoodDetailResponse,
    FoodItemResponse,
    FoodListResponse,
)
from app.schemas.meal import (
    MealCreateRequest,
    MealItemCreate,
    MealItemResponse,
    MealListResponse,
    MealRecordListItem,
    MealRecordResponse,
)
from app.schemas.nutrition import DailyTargetResponse, NutritionTotals, TargetBasis
from app.schemas.profile import ProfileRequest, ProfileResponse
from app.schemas.user import UserWithProfileResponse

__all__ = [
    "LoginRequest",
    "RegisterRequest",
    "TokenResponse",
    "UserResponse",
    "DailyDashboardResponse",
    "DashboardProgress",
    "NutrientProgress",
    "ErrorDetail",
    "ErrorInfo",
    "ErrorResponse",
    "DetectFoodResponse",
    "DetectionItem",
    "FoodDetailResponse",
    "FoodItemResponse",
    "FoodListResponse",
    "MealCreateRequest",
    "MealItemCreate",
    "MealItemResponse",
    "MealListResponse",
    "MealRecordListItem",
    "MealRecordResponse",
    "DailyTargetResponse",
    "NutritionTotals",
    "TargetBasis",
    "ProfileRequest",
    "ProfileResponse",
    "UserWithProfileResponse",
]
