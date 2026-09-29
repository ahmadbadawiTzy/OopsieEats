from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.user import User
from app.schemas.profile import ProfileRequest, ProfileResponse
from app.schemas.user import UserWithProfileResponse
from app.services.profile_service import get_profile_by_user_id, upsert_profile

router = APIRouter(prefix="/users", tags=["Users & Profiles"])


@router.get(
    "/me",
    response_model=UserWithProfileResponse,
    status_code=status.HTTP_200_OK,
    summary="Dapatkan informasi pengguna saat ini beserta profil",
)
def get_me(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = get_profile_by_user_id(db, current_user.id)
    return UserWithProfileResponse(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        profile=ProfileResponse.model_validate(profile) if profile else None,
    )


@router.put(
    "/me/profile",
    response_model=ProfileResponse,
    status_code=status.HTTP_200_OK,
    summary="Buat atau perbarui profil pengguna",
)
def update_profile(
    req: ProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = upsert_profile(db, current_user.id, req)
    return profile
