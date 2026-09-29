from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.core.errors import AppError
from app.models.user import User
from app.schemas.nutrition import DailyTargetResponse
from app.services.nutrition_service import calculate_daily_target
from app.services.profile_service import get_profile_by_user_id

router = APIRouter(prefix="/nutrition", tags=["Nutrition"])


@router.get(
    "/target",
    response_model=DailyTargetResponse,
    status_code=status.HTTP_200_OK,
    summary="Dapatkan target gizi harian pengguna berdasarkan profil",
)
def get_daily_target(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = get_profile_by_user_id(db, current_user.id)
    if not profile:
        raise AppError(
            status_code=status.HTTP_400_BAD_REQUEST,
            code="PROFILE_INCOMPLETE",
            message="Profil pengguna belum lengkap. Silakan lengkapi profil terlebih dahulu.",
        )

    target = calculate_daily_target(
        age=profile.age,
        sex=profile.sex,
        weight_kg=profile.weight_kg,
        height_cm=profile.height_cm,
        activity_level=profile.activity_level,
        goal=profile.goal,
    )
    return target
