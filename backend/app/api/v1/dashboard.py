from datetime import date, datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.core.errors import AppError
from app.models.user import User
from app.schemas.dashboard import DailyDashboardResponse
from app.services.dashboard_service import get_daily_dashboard

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get(
    "/daily",
    response_model=DailyDashboardResponse,
    status_code=status.HTTP_200_OK,
    summary="Ringkasan asupan gizi harian terhadap target",
)
def get_daily_summary(
    date_str: Optional[str] = Query(
        None, alias="date", description="Tanggal YYYY-MM-DD (default hari ini)"
    ),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if date_str:
        try:
            target_date = date.fromisoformat(date_str)
        except ValueError:
            raise AppError(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                code="VALIDATION_ERROR",
                message="Format tanggal harus YYYY-MM-DD.",
                details=[{"field": "date", "message": "Format harus YYYY-MM-DD."}],
            ) from None
    else:
        target_date = datetime.now(timezone.utc).date()

    return get_daily_dashboard(db, current_user.id, target_date)
