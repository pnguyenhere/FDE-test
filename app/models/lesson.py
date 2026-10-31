
from datetime import date, time, datetime

from sqlalchemy import (
    String,
    Date,
    Time,
    Integer,
    DateTime,
    Text,
    ForeignKey,
    CheckConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class Lesson(Base):
    __tablename__ = "lessons"

    __table_args__ = (
        CheckConstraint(
            "duration_min > 0",
            name="ck_lesson_duration_positive",
        ),
        CheckConstraint(
            "status IN ('booked', 'cancelled', 'no_show')",
            name="ck_lesson_status",
        ),
        CheckConstraint(
            """
            (status = 'cancelled' AND cancelled_at IS NOT NULL)
            OR
            (status <> 'cancelled' AND cancelled_at IS NULL)
            """,
            name="chk_cancellation_timestamp",
        ),
    )

    lesson_id: Mapped[str] = mapped_column(
        String(30), primary_key=True
    )
    lesson_date: Mapped[date] = mapped_column(
        Date, nullable=False
    )
    start_time: Mapped[time] = mapped_column(
        Time, nullable=False
    )
    duration_min: Mapped[int] = mapped_column(
        Integer, nullable=False
    )
    student_name: Mapped[str] = mapped_column(
        String(150), nullable=False
    )
    tutor_id: Mapped[str] = mapped_column(
        String(20),
        ForeignKey("tutors.tutor_id"),
        nullable=False,
    )
    room: Mapped[str] = mapped_column(
        String(20), nullable=False
    )
    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="booked"
    )
    cancelled_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    note: Mapped[str | None] = mapped_column(
        Text, nullable=True
    )

    tutor = relationship("Tutor", back_populates="lessons")
    events = relationship("LessonEvent", back_populates="lesson")
