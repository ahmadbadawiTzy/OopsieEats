from typing import Optional

from pydantic import BaseModel, ConfigDict

from app.schemas.profile import ProfileResponse


class UserWithProfileResponse(BaseModel):
    id: int
    email: str
    full_name: str
    profile: Optional[ProfileResponse] = None

    model_config = ConfigDict(from_attributes=True)
