from datetime import datetime, timezone
from decimal import Decimal
from typing import TYPE_CHECKING

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    Numeric,
    SmallInteger,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.user import User


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class Profile(Base):
    __tablename__ = "profiles"

    id: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True
    )
    user_id: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )
    age: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    sex: Mapped[str] = mapped_column(
        Enum("male", "female", name="profile_sex_enum"), nullable=False
    )
    weight_kg: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)
    height_cm: Mapped[Decimal] = mapped_column(Numeric(5, 2), nullable=False)
    activity_level: Mapped[str] = mapped_column(
        Enum(
            "sedentary",
            "light",
            "moderate",
            "active",
            "very_active",
            name="profile_activity_enum",
        ),
        nullable=False,
    )
    goal: Mapped[str] = mapped_column(
        Enum("lose_weight", "maintain_weight", "gain_weight", name="profile_goal_enum"),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=utc_now, onupdate=utc_now, nullable=False
    )

    user: Mapped["User"] = relationship("User", back_populates="profile")

    __table_args__ = (
        CheckConstraint("age >= 15 AND age <= 100", name="chk_profile_age"),
        CheckConstraint("weight_kg >= 20.00 AND weight_kg <= 300.00", name="chk_profile_weight"),
        CheckConstraint("height_cm >= 100.00 AND height_cm <= 250.00", name="chk_profile_height"),
    )
