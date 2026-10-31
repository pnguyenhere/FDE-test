
from datetime import datetime, timedelta

from app.repositories.schedule_repository import get_lessons_by_date


def get_daily_schedule(db, target_date):
    rows = get_lessons_by_date(db, target_date)

    lessons = []

    for lesson, tutor in rows:
        start = datetime.combine(
            lesson.lesson_date,
            lesson.start_time,
        )
        end = start + timedelta(minutes=lesson.duration_min)

        lessons.append({
            "lesson_id": lesson.lesson_id,
            "date": lesson.lesson_date.isoformat(),
            "start_time": lesson.start_time.strftime("%H:%M"),
            "end_time": end.strftime("%H:%M"),
            "duration_min": lesson.duration_min,
            "student_name": lesson.student_name,
            "tutor_id": tutor.tutor_id,
            "tutor_name": tutor.tutor_name,
            "subject": tutor.subject,
            "room": lesson.room,
            "status": lesson.status,
            "note": lesson.note,
            "warnings": [],
            "_start": start,
            "_end": end,
        })

    # Cancelled lessons do not reserve a slot.
    # No-show lessons still reserve the original slot.
    active_lessons = [
        lesson for lesson in lessons
        if lesson["status"] != "cancelled"
    ]

    # Detect overlapping tutor, student, and room bookings.
    for i, first in enumerate(active_lessons):
        for second in active_lessons[i + 1:]:
            overlap = (
                first["_start"] < second["_end"]
                and second["_start"] < first["_end"]
            )

            if not overlap:
                continue

            is_exam_pair = (
                first["tutor_id"] == second["tutor_id"]
                and first["room"] == second["room"]
                and first["note"] == "exam pair - half price"
                and second["note"] == "exam pair - half price"
            )

            if first["tutor_id"] == second["tutor_id"] and not is_exam_pair:
                first["warnings"].append(
                    f"Tutor conflict with {second['lesson_id']}"
                )
                second["warnings"].append(
                    f"Tutor conflict with {first['lesson_id']}"
                )

            if first["student_name"] == second["student_name"]:
                first["warnings"].append(
                    f"Student conflict with {second['lesson_id']}"
                )
                second["warnings"].append(
                    f"Student conflict with {first['lesson_id']}"
                )

            if first["room"] == second["room"] and not is_exam_pair:
                first["warnings"].append(
                    f"Room conflict with {second['lesson_id']}"
                )
                second["warnings"].append(
                    f"Room conflict with {first['lesson_id']}"
                )

            if is_exam_pair:
                first["note"] = f"Exam pair with {second["student_name"]} - {second["lesson_id"]}, half price"
                second["note"] = f"Exam pair with {first["student_name"]} - {first["lesson_id"]}, half price"

    # Remove internal datetime fields before returning the response.
    for lesson in lessons:
        del lesson["_start"]
        del lesson["_end"]

    return {
        "date": target_date.isoformat(),
        "total_lessons": len(lessons),
        "lessons": lessons,
    }
