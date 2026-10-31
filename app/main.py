
from datetime import date
from pathlib import Path

from fastapi import FastAPI, Depends, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.schedule import router as schedule_router
from app.services.schedule_service import get_daily_schedule

BASE_DIR = Path(__file__).resolve().parent

app = FastAPI(
    title="Bright Path API",
    description="Daily schedule dashboard for Bright Path",
    version="1.0.0",
)

app.include_router(schedule_router)

app.mount(
    "/static",
    StaticFiles(directory=BASE_DIR / "static"),
    name="static",
)

templates = Jinja2Templates(
    directory=BASE_DIR / "templates"
)

@app.get("/", response_class=HTMLResponse)
@app.get("/dashboard", response_class=HTMLResponse)
def dashboard(
    request: Request,
    target_date: date | None = None,
    db: Session = Depends(get_db),
):
    # Automatically use today's date if none is provided.
    selected_date = target_date or date.today()

    schedule = get_daily_schedule(db, selected_date)

    return templates.TemplateResponse(
        request=request,
        name="dashboard.html",
        context={
            "schedule": schedule,
            "selected_date": selected_date.isoformat(),
        },
    )


@app.get("/dashboard/schedule", response_class=HTMLResponse)
def dashboard_schedule(
    request: Request,
    target_date: date,
    db: Session = Depends(get_db),
):
    schedule = get_daily_schedule(db, target_date)

    return templates.TemplateResponse(
        request=request,
        name="partials/schedule_content.html",
        context={
            "schedule": schedule,
            "selected_date": target_date.isoformat(),
        },
    )


@app.get("/health")
def health_check():
    return {"status": "healthy"}


@app.get("/health/db")
def database_health_check(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"database": "connected"}
