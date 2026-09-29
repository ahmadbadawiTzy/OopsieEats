from typing import List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.core.errors import AppError
from app.models.food import Food


def list_foods(
    db: Session,
    q: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
) -> Tuple[List[Food], int]:
    stmt = select(Food).options(joinedload(Food.nutrition)).where(Food.is_active.is_(True))

    if q and q.strip():
        search_term = f"%{q.strip()}%"
        stmt = stmt.where(Food.name.ilike(search_term))

    count_stmt = select(func.count()).select_from(stmt.subquery())
    total = db.scalar(count_stmt) or 0

    offset = (page - 1) * page_size
    stmt = stmt.order_by(Food.name.asc()).offset(offset).limit(page_size)
    items = list(db.scalars(stmt).unique().all())

    return items, total


def get_food_by_id(db: Session, food_id: int) -> Food:
    stmt = (
        select(Food)
        .options(joinedload(Food.nutrition))
        .where(Food.id == food_id, Food.is_active.is_(True))
    )
    food = db.scalars(stmt).first()
    if not food:
        raise AppError(
            status_code=404,
            code="FOOD_NOT_FOUND",
            message="Makanan tidak ditemukan.",
        )
    return food


def get_food_by_yolo_class(db: Session, yolo_class: str) -> Optional[Food]:
    stmt = (
        select(Food)
        .options(joinedload(Food.nutrition))
        .where(Food.yolo_class == yolo_class, Food.is_active.is_(True))
    )
    return db.scalars(stmt).first()
