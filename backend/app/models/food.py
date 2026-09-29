from datetime import datetime, timezone
from decimal import Decimal
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.meal import MealItem


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class Food(Base):
    __tablename__ = "foods"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    yolo_class: Mapped[Optional[str]] = mapped_column(
        String(100), unique=True, nullable=True, index=True
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    nutrition: Mapped["FoodNutrition"] = relationship(
        "FoodNutrition", back_populates="food", uselist=False, cascade="all, delete-orphan"
    )
    meal_items: Mapped[List["MealItem"]] = relationship("MealItem", back_populates="food")


class FoodNutrition(Base):
    __tablename__ = "food_nutrition"

    food_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("foods.id", ondelete="CASCADE"), primary_key=True
    )
    calories_kcal: Mapped[Decimal] = mapped_column(Numeric(7, 2), nullable=False)
    protein_g: Mapped[Decimal] = mapped_column(Numeric(7, 2), nullable=False)
    carbs_g: Mapped[Decimal] = mapped_column(Numeric(7, 2), nullable=False)
    fat_g: Mapped[Decimal] = mapped_column(Numeric(7, 2), nullable=False)
    source: Mapped[str] = mapped_column(String(255), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=utc_now, onupdate=utc_now, nullable=False
    )

    food: Mapped["Food"] = relationship("Food", back_populates="nutrition")

    __table_args__ = (
        CheckConstraint("calories_kcal >= 0", name="chk_food_calories"),
        CheckConstraint("protein_g >= 0", name="chk_food_protein"),
        CheckConstraint("carbs_g >= 0", name="chk_food_carbs"),
        CheckConstraint("fat_g >= 0", name="chk_food_fat"),
    )
