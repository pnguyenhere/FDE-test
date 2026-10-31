
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