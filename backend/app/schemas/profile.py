from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

SexType = Literal["male", "female"]
ActivityLevelType = Literal["sedentary", "light", "moderate", "active", "very_active"]
GoalType = Literal["lose_weight", "maintain_weight", "gain_weight"]


class ProfileRequest(BaseModel):
    age: int = Field(..., ge=15, le=100, description="Usia 15-100 tahun")
    sex: SexType
    weight_kg: float = Field(..., ge=20.0, le=300.0, description="Berat 20-300 kg")
    height_cm: float = Field(..., ge=100.0, le=250.0, description="Tinggi 100-250 cm")
    activity_level: ActivityLevelType
    goal: GoalType

    model_config = ConfigDict(extra="forbid")


class ProfileResponse(BaseModel):
    age: int
    sex: SexType
    weight_kg: float
    height_cm: float
    activity_level: ActivityLevelType
    goal: GoalType

    model_config = ConfigDict(from_attributes=True)
