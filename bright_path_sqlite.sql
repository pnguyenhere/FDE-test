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

INSERT INTO tutors (tutor_id, tutor_name, subject, phone) VALUES
('T1', 'Ngoc Anh', 'Maths', '090xxx1122'),
('T2', 'Pham Duc', 'English', '090xxx3344'),
('T3', 'Le Thu', 'Physics', '090xxx5566');

INSERT INTO lessons (
    lesson_id, lesson_date, start_time, duration_min, student_name,
    tutor_id, room, status, cancelled_at, note
) VALUES
('L001','2026-03-03','09:00',60,'Le Minh Chau','T1','R1','booked',NULL,NULL),
('L002','2026-03-03','09:00',60,'Tran Bao Long','T2','R2','booked',NULL,NULL),
('L003','2026-03-03','10:30',90,'Nguyen Thi Ha','T1','R1','booked',NULL,NULL),
('L004','2026-03-03','10:30',60,'Do Van Kien','T3','R3','booked',NULL,NULL),
('L005','2026-03-03','14:00',60,'Vu Ha My','T2','R2','cancelled','2026-03-03T08:15:00+07:00','family cancelled'),
('L006','2026-03-03','15:30',90,'Bui An Nhien','T1','R1','booked',NULL,NULL),
('L007','2026-03-04','09:00',60,'Le Minh Chau','T3','R3','booked',NULL,NULL),
('L008','2026-03-04','09:00',60,'Le Minh Chau','T2','R2','booked',NULL,'added by phone; family confirmed'),
('L009','2026-03-04','11:00',90,'Tran Bao Long','T1','R1','booked',NULL,'exam pair - half price'),
('L010','2026-03-04','11:00',90,'Nguyen Thi Ha','T1','R1','booked',NULL,'exam pair - half price'),
('L011','2026-03-04','14:00',60,'Do Van Kien','T3','R3','booked',NULL,NULL),
('L012','2026-03-04','16:00',60,'Vu Ha My','T2','R2','booked',NULL,NULL),
('L013','2026-03-05','09:00',60,'Bui An Nhien','T1','R1','booked',NULL,NULL),
('L014','2026-03-05','10:30',90,'Le Minh Chau','T3','R3','booked',NULL,NULL),
('L015','2026-03-05','13:00',60,'Tran Bao Long','T2','R2','no_show',NULL,NULL),
('L016','2026-03-05','14:30',90,'Nguyen Thi Ha','T1','R1','booked',NULL,NULL),
('L017','2026-03-05','16:00',60,'Do Van Kien','T3','R3','cancelled','2026-03-05T14:40:00+07:00','tutor sick'),
('L018','2026-03-06','09:00',60,'Vu Ha My','T1','R1','booked',NULL,NULL),
('L019','2026-03-06','09:00',60,'Le Minh Chau','T2','R2','booked',NULL,NULL),
('L020','2026-03-06','10:30',90,'Bui An Nhien','T3','R3','booked',NULL,NULL),
('L021','2026-03-06','11:30',60,'Tran Bao Long','T1','R1','booked',NULL,NULL),
('L022','2026-03-06','13:00',60,'Tran Bao Long','T1','R1','booked',NULL,NULL),
('L023','2026-03-06','14:30',60,'Nguyen Thi Ha','T2','R2','booked',NULL,NULL),
('L024','2026-03-06','16:00',60,'Do Van Kien','T1','R1','booked',NULL,NULL),
('L025','2026-03-06','17:30',60,'Vu Ha My','T1','R1','booked',NULL,NULL),
('L026','2026-03-06','19:00',60,'Le Minh Chau','T1','R1','booked',NULL,NULL),
('L027','2026-03-06','20:30',60,'Bui An Nhien','T1','R1','booked',NULL,NULL),
('L028','2026-03-07','09:00',90,'Tran Bao Long','T3','R3','booked',NULL,NULL),
('L029','2026-03-07','11:00',60,'Nguyen Thi Ha','T2','R2','booked',NULL,NULL),
('L030','2026-03-07','15:00',60,'Bui An Nhien','T1','R1','booked',NULL,NULL),
('L031','2026-03-08','10:00',60,'Do Van Kien','T1','R1','booked',NULL,NULL),
('L032','2026-03-09','10:00',60,'Vu Ha My','T3','R3','booked',NULL,'moved from Sunday at the family''s request'),
('L033','2026-03-10','09:00',60,'Le Minh Chau','T1','R1','booked',NULL,NULL),
('L034','2026-03-10','09:00',60,'Tran Bao Long','T1','R2','booked',NULL,NULL);

COMMIT;
