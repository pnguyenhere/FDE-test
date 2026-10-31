
from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.services.schedule_service import get_daily_schedule

router = APIRouter(prefix="/api", tags=["Schedule"])


@router.get("/schedule")
def read_daily_schedule(
    target_date: date = Query(alias="date"),
    db: Session = Depends(get_db),
):
    return get_daily_schedule(db, target_date)
