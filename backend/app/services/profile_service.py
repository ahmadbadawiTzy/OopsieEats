from decimal import Decimal
from typing import Optional

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.profile import Profile
from app.schemas.profile import ProfileRequest


def get_profile_by_user_id(db: Session, user_id: int) -> Optional[Profile]:
    stmt = select(Profile).where(Profile.user_id == user_id)
    return db.scalars(stmt).first()


def upsert_profile(db: Session, user_id: int, req: ProfileRequest) -> Profile:
    profile = get_profile_by_user_id(db, user_id)
    if profile:
        profile.age = req.age
        profile.sex = req.sex
        profile.weight_kg = Decimal(str(req.weight_kg))
        profile.height_cm = Decimal(str(req.height_cm))
        profile.activity_level = req.activity_level
        profile.goal = req.goal
    else:
        profile = Profile(
            user_id=user_id,
            age=req.age,
            sex=req.sex,
            weight_kg=Decimal(str(req.weight_kg)),
            height_cm=Decimal(str(req.height_cm)),
            activity_level=req.activity_level,
            goal=req.goal,
        )
        db.add(profile)

    db.commit()
    db.refresh(profile)
    return profile
