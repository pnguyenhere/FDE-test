-- Bright Path SQLite schema and seed data
PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS tutors (
    tutor_id VARCHAR(20) PRIMARY KEY,
    tutor_name VARCHAR(100) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    phone VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS lessons (
    lesson_id VARCHAR(30) PRIMARY KEY,
    lesson_date DATE NOT NULL,
    start_time TIME NOT NULL,
    duration_min INTEGER NOT NULL CHECK (duration_min > 0),
    student_name VARCHAR(150) NOT NULL,
    tutor_id VARCHAR(20) NOT NULL,
    room VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'booked'
        CHECK (status IN ('booked', 'cancelled', 'no_show')),
    cancelled_at TEXT,
    note TEXT,
    CONSTRAINT chk_cancellation_timestamp CHECK (
        (status = 'cancelled' AND cancelled_at IS NOT NULL)
        OR (status <> 'cancelled' AND cancelled_at IS NULL)
    ),
    CONSTRAINT fk_lessons_tutor FOREIGN KEY (tutor_id)
        REFERENCES tutors(tutor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS lesson_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    lesson_id VARCHAR(30) NOT NULL,
    event_type VARCHAR(30) NOT NULL CHECK (
        event_type IN (
            'CREATED', 'TUTOR_NOTIFIED', 'MOVED',
            'CANCELLED', 'NO_SHOW_MARKED'
        )
    ),
    occurred_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actor VARCHAR(100),
    previous_data TEXT CHECK (previous_data IS NULL OR json_valid(previous_data)),
    new_data TEXT CHECK (new_data IS NULL OR json_valid(new_data)),
    related_event_id INTEGER,
    CONSTRAINT fk_events_lesson FOREIGN KEY (lesson_id)
        REFERENCES lessons(lesson_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_related_event FOREIGN KEY (related_event_id)
        REFERENCES lesson_events(event_id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_lessons_date ON lessons(lesson_date);
CREATE INDEX IF NOT EXISTS idx_lessons_tutor_date ON lessons(tutor_id, lesson_date);
CREATE INDEX IF NOT EXISTS idx_lessons_room_date ON lessons(room, lesson_date);
CREATE INDEX IF NOT EXISTS idx_lessons_student_date ON lessons(student_name, lesson_date);
CREATE INDEX IF NOT EXISTS idx_events_lesson_time ON lesson_events(lesson_id, occurred_at DESC);

COMMIT;
