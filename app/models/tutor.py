
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class Tutor(Base):
    __tablename__ = "tutors"

    tutor_id: Mapped[str] = mapped_column(
        String(20), primary_key=True
    )
    tutor_name: Mapped[str] = mapped_column(
        String(100), nullable=False
    )
    subject: Mapped[str] = mapped_column(
        String(100), nullable=False
    )
    phone: Mapped[str | None] = mapped_column(
        String(30), nullable=True
    )

    lessons = relationship("Lesson", back_populates="tutor")
