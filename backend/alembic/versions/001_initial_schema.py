"""initial schema

Revision ID: 001_initial_schema
Revises:
Create Date: 2026-09-29 20:00:00.000000

"""

from typing import Sequence, Union

import sqlalchemy as sa

from alembic import op

revision: str = "001_initial_schema"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Helper for big integer with sqlite compatibility
    big_int_type = sa.BigInteger().with_variant(sa.Integer, "sqlite")

    # 1. users
    op.create_table(
        "users",
        sa.Column("id", big_int_type, autoincrement=True, nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("full_name", sa.String(length=100), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    # 2. profiles
    op.create_table(
        "profiles",
        sa.Column("id", big_int_type, autoincrement=True, nullable=False),
        sa.Column("user_id", big_int_type, nullable=False),
        sa.Column("age", sa.SmallInteger(), nullable=False),
        sa.Column("sex", sa.Enum("male", "female", name="profile_sex_enum"), nullable=False),
        sa.Column("weight_kg", sa.Numeric(precision=5, scale=2), nullable=False),
        sa.Column("height_cm", sa.Numeric(precision=5, scale=2), nullable=False),
        sa.Column(
            "activity_level",
            sa.Enum(
                "sedentary",
                "light",
                "moderate",
                "active",
                "very_active",
                name="profile_activity_enum",
            ),
            nullable=False,
        ),
        sa.Column(
            "goal",
            sa.Enum("lose_weight", "maintain_weight", "gain_weight", name="profile_goal_enum"),
            nullable=False,
        ),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.CheckConstraint("age >= 15 AND age <= 100", name="chk_profile_age"),
        sa.CheckConstraint("weight_kg >= 20.00 AND weight_kg <= 300.00", name="chk_profile_weight"),
        sa.CheckConstraint(
            "height_cm >= 100.00 AND height_cm <= 250.00", name="chk_profile_height"
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id"),
    )

    # 3. foods
    op.create_table(
        "foods",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("name", sa.String(length=100), nullable=False),
        sa.Column("yolo_class", sa.String(length=100), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("1")),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("name"),
        sa.UniqueConstraint("yolo_class"),
    )
    op.create_index("ix_foods_name", "foods", ["name"], unique=True)
    op.create_index("ix_foods_is_active", "foods", ["is_active"])

    # 4. food_nutrition
    op.create_table(
        "food_nutrition",
        sa.Column("food_id", sa.Integer(), nullable=False),
        sa.Column("calories_kcal", sa.Numeric(precision=7, scale=2), nullable=False),
        sa.Column("protein_g", sa.Numeric(precision=7, scale=2), nullable=False),
        sa.Column("carbs_g", sa.Numeric(precision=7, scale=2), nullable=False),
        sa.Column("fat_g", sa.Numeric(precision=7, scale=2), nullable=False),
        sa.Column("source", sa.String(length=255), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
        sa.CheckConstraint("calories_kcal >= 0", name="chk_food_calories"),
        sa.CheckConstraint("protein_g >= 0", name="chk_food_protein"),
        sa.CheckConstraint("carbs_g >= 0", name="chk_food_carbs"),
        sa.CheckConstraint("fat_g >= 0", name="chk_food_fat"),
        sa.ForeignKeyConstraint(["food_id"], ["foods.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("food_id"),
    )

    # 5. meal_records
    op.create_table(
        "meal_records",
        sa.Column("id", big_int_type, autoincrement=True, nullable=False),
        sa.Column("user_id", big_int_type, nullable=False),
        sa.Column(
            "meal_type",
            sa.Enum("breakfast", "lunch", "dinner", "snack", name="meal_type_enum"),
            nullable=False,
        ),
        sa.Column("consumed_at", sa.DateTime(), nullable=False),
        sa.Column("consumed_date", sa.Date(), nullable=False),
        sa.Column("total_calories_kcal", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column("total_protein_g", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column("total_carbs_g", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column("total_fat_g", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("idx_meal_records_user_date", "meal_records", ["user_id", "consumed_date"])
    op.create_index("idx_meal_records_user_consumed_at", "meal_records", ["user_id", "consumed_at"])

    # 6. meal_items
    op.create_table(
        "meal_items",
        sa.Column("id", big_int_type, autoincrement=True, nullable=False),
        sa.Column("meal_id", big_int_type, nullable=False),
        sa.Column("food_id", sa.Integer(), nullable=False),
        sa.Column("portion_grams", sa.Numeric(precision=7, scale=2), nullable=False),
        sa.Column("calories_kcal", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column("protein_g", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column("carbs_g", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column("fat_g", sa.Numeric(precision=8, scale=2), nullable=False),
        sa.Column(
            "source",
            sa.Enum("detected", "corrected", "manual", name="meal_item_source_enum"),
            nullable=False,
        ),
        sa.Column("detection_confidence", sa.Numeric(precision=4, scale=3), nullable=True),
        sa.CheckConstraint(
            "portion_grams > 0 AND portion_grams <= 5000",
            name="chk_meal_item_portion",
        ),
        sa.ForeignKeyConstraint(["food_id"], ["foods.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["meal_id"], ["meal_records.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("idx_meal_items_meal_id", "meal_items", ["meal_id"])
    op.create_index("idx_meal_items_food_id", "meal_items", ["food_id"])

    # 7. revoked_tokens
    op.create_table(
        "revoked_tokens",
        sa.Column("jti", sa.String(length=36), nullable=False),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("jti"),
    )
    op.create_index("idx_revoked_tokens_expires_at", "revoked_tokens", ["expires_at"])


def downgrade() -> None:
    op.drop_table("revoked_tokens")
    op.drop_table("meal_items")
    op.drop_table("meal_records")
    op.drop_table("food_nutrition")
    op.drop_table("foods")
    op.drop_table("profiles")
    op.drop_table("users")
