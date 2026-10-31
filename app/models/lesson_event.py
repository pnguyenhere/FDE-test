
from datetime import datetime

from sqlalchemy import (
    Integer,
    String,
    DateTime,
    ForeignKey,
    CheckConstraint,
    JSON,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class LessonEvent(Base):
    __tablename__ = "lesson_events"

    __table_args__ = (
        CheckConstraint(
            """
            event_type IN (
                'CREATED',
                'TUTOR_NOTIFIED',
                'MOVED',
                'CANCELLED',
                'NO_SHOW_MARKED'
            )
            """,
            name="ck_lesson_event_type",
        ),
    )

    event_id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        autoincrement=True,
    )
    lesson_id: Mapped[str] = mapped_column(
        String(30),
        ForeignKey("lessons.lesson_id"),
        nullable=False,
    )
    event_type: Mapped[str] = mapped_column(
        String(30), nullable=False
    )
    occurred_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )
    actor: Mapped[str | None] = mapped_column(
        String(100), nullable=True
    )
    previous_data: Mapped[dict | None] = mapped_column(
        JSON, nullable=True
    )
    new_data: Mapped[dict | None] = mapped_column(
        JSON, nullable=True
    )
    related_event_id: Mapped[int | None] = mapped_column(
        Integer,
        ForeignKey("lesson_events.event_id"),
        nullable=True,
    )

    lesson = relationship("Lesson", back_populates="events")
    related_event = relationship(
        "LessonEvent",
        remote_side="LessonEvent.event_id",
    )
