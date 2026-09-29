from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.dashboard import router as dashboard_router
from app.api.v1.foods import router as foods_router
from app.api.v1.meals import router as meals_router
from app.api.v1.nutrition import router as nutrition_router
from app.api.v1.users import router as users_router

api_v1_router = APIRouter(prefix="/api/v1")

api_v1_router.include_router(auth_router)
api_v1_router.include_router(users_router)
api_v1_router.include_router(nutrition_router)
api_v1_router.include_router(foods_router)
api_v1_router.include_router(meals_router)
api_v1_router.include_router(dashboard_router)
