
from datetime import date

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Lesson, Tutor


def get_lessons_by_date(db: Session, target_date: date):
    statement = (
        select(Lesson, Tutor)
        .join(Tutor, Lesson.tutor_id == Tutor.tutor_id)
        .where(Lesson.lesson_date == target_date)
        .order_by(Lesson.start_time, Lesson.lesson_id)
    )

    return db.execute(statement).all()
