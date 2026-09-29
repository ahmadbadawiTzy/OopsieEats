from datetime import date, datetime, timezone
from decimal import Decimal
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    Date,
    DateTime,
    Enum,
    ForeignKey,
    Index,
    Integer,
    Numeric,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.food import Food
    from app.models.user import User


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class MealRecord(Base):
    __tablename__ = "meal_records"

    id: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True
    )
    user_id: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    meal_type: Mapped[str] = mapped_column(
        Enum("breakfast", "lunch", "dinner", "snack", name="meal_type_enum"), nullable=False
    )
    consumed_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    consumed_date: Mapped[date] = mapped_column(Date, nullable=False)
    total_calories_kcal: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    total_protein_g: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    total_carbs_g: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    total_fat_g: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    user: Mapped["User"] = relationship("User", back_populates="meal_records")
    items: Mapped[List["MealItem"]] = relationship(
        "MealItem", back_populates="meal_record", cascade="all, delete-orphan"
    )

    __table_args__ = (
        Index("idx_meal_records_user_date", "user_id", "consumed_date"),
        Index("idx_meal_records_user_consumed_at", "user_id", "consumed_at"),
    )


class MealItem(Base):
    __tablename__ = "meal_items"

    id: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True
    )
    meal_id: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"),
        ForeignKey("meal_records.id", ondelete="CASCADE"),
        nullable=False,
    )
    food_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("foods.id", ondelete="RESTRICT"), nullable=False
    )
    portion_grams: Mapped[Decimal] = mapped_column(Numeric(7, 2), nullable=False)
    calories_kcal: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    protein_g: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    carbs_g: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    fat_g: Mapped[Decimal] = mapped_column(Numeric(8, 2), nullable=False)
    source: Mapped[str] = mapped_column(
        Enum("detected", "corrected", "manual", name="meal_item_source_enum"), nullable=False
    )
    detection_confidence: Mapped[Optional[Decimal]] = mapped_column(Numeric(4, 3), nullable=True)

    meal_record: Mapped["MealRecord"] = relationship("MealRecord", back_populates="items")
    food: Mapped["Food"] = relationship("Food", back_populates="meal_items")

    __table_args__ = (
        CheckConstraint(
            "portion_grams > 0 AND portion_grams <= 5000", name="chk_meal_item_portion"
        ),
        Index("idx_meal_items_meal_id", "meal_id"),
        Index("idx_meal_items_food_id", "food_id"),
    )
