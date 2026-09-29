import csv
import logging
import os
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.session import SessionLocal, engine
from app.models.food import Food, FoodNutrition

logger = logging.getLogger("nutriview.seed")


def seed_foods_from_csv(db: Session, csv_path: str) -> int:
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"Seed file not found: {csv_path}")

    seeded_count = 0
    with open(csv_path, mode="r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row["name"].strip()
            yolo_class = row["yolo_class"].strip() or None
            calories = Decimal(row["calories_kcal"].strip())
            protein = Decimal(row["protein_g"].strip())
            carbs = Decimal(row["carbs_g"].strip())
            fat = Decimal(row["fat_g"].strip())
            source = row["source"].strip()

            stmt = select(Food).where(Food.name == name)
            food = db.scalars(stmt).first()

            if not food:
                food = Food(
                    name=name,
                    yolo_class=yolo_class,
                    is_active=True,
                )
                db.add(food)
                db.flush()

                nutrition = FoodNutrition(
                    food_id=food.id,
                    calories_kcal=calories,
                    protein_g=protein,
                    carbs_g=carbs,
                    fat_g=fat,
                    source=source,
                )
                db.add(nutrition)
                seeded_count += 1
            else:
                food.yolo_class = yolo_class
                if food.nutrition:
                    food.nutrition.calories_kcal = calories
                    food.nutrition.protein_g = protein
                    food.nutrition.carbs_g = carbs
                    food.nutrition.fat_g = fat
                    food.nutrition.source = source
                else:
                    nutrition = FoodNutrition(
                        food_id=food.id,
                        calories_kcal=calories,
                        protein_g=protein,
                        carbs_g=carbs,
                        fat_g=fat,
                        source=source,
                    )
                    db.add(nutrition)
                seeded_count += 1

    db.commit()
    logger.info(f"Seeded {seeded_count} foods successfully.")
    return seeded_count


def run_seed():
    logging.basicConfig(level=logging.INFO)
    # Ensure tables exist (helpful for local/test dev)
    Base.metadata.create_all(bind=engine)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(current_dir, "foods.csv")
    with SessionLocal() as db:
        count = seed_foods_from_csv(db, csv_path)
        print(f"Successfully seeded {count} food items from {csv_path}")


if __name__ == "__main__":
    run_seed()
