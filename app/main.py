
from fastapi import FastAPI, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session


from app.db.database import get_db

app = FastAPI(
    title="Bright Path API",
    description="Daily schedule dashboard for Bright Path",
    version="1.0.0",
)


@app.get("/health")
def health_check():
    return {"status": "healthy"}


@app.get("/health/db")
def database_health_check(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"database": "connected"}
