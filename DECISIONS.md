# Phase 1: Read the situation

## 1. Understanding the existing data

The provided spreadsheet contains two logical entities:

- **Tutors:** tutor_id, tutor_name, subject, phone.
- **Lessons:** lesson_id, date, start_time, duration_min, student, tutor_id, room, status, cancelled_at, note.

The lesson end time can be calculated from start_time and duration_min.

## 2. Observed data

The sample data reveals several inconsistencies and potential exceptions.

| Record | Observation | Assessment |
|---|---|---|
| L032 | Scheduled on Monday (2026-03-09), when the centre is closed. | Business rule violation (Opening days) |
| T1, 2026-03-06 | Has seven bookings, exceeding the maximum of six. | Business rule violation (Tutor load) |
| L033, L034 | T1 is assigned to two lessons simultaneously in different rooms. | Tutor scheduling conflict |
| L007, L008 | Le Minh Chau has two simultaneous bookings with different tutors. | Potential student scheduling conflict |
| L005 | Cancelled 5 hours and 45 minutes before the lesson. | Free cancellation |
| L017 | Cancelled 1 hour and 20 minutes before the lesson due to tutor illness. | Cancellation policy requires clarification |
| L015 | Marked as no_show. | Room and tutor slot should remain occupied |

Historical records should not be automatically modified or deleted simply because they violate current business rules. The system should preserve the original data and distinguish observed information from validation results.

## 3. Questions, decisions, and assumptions

The following points require clarification. To keep the implementation moving, I have documented my current interpretation and the assumptions I would use if the owner cannot provide an answer.

| Question / Ambiguity | How the answer affects the design | Initial assumption |
|---|---|---|
| Can a student have multiple lessons at the same time? | Determines whether student scheduling conflicts should be prevented or flagged. | A student cannot attend two lessons simultaneously. |
| Does the tutor's six-booking limit include cancelled bookings and no-shows? | Determines how daily tutor workload is calculated. | Only bookings that have not been cancelled count toward the limit. No-shows still count because the tutor's time was reserved. |
| Can the owner authorize bookings on normally closed days? | Determines whether operating-day restrictions are absolute or can be overridden. | Monday bookings are not allowed unless explicitly authorized by the owner. |
| How should tutor-initiated cancellations be handled? | The current policy only describes family cancellations. Applying the same four-hour rule to tutor-initiated cancellations could incorrectly charge families. | Tutor-initiated cancellations do not incur charges for families and release the room and tutor's slot. |
| Should modifications preserve previous values, timestamps, and the responsible user? | Determines whether an audit history is needed in addition to storing the latest booking state. | Every modification should be recorded so previous booking information can be reconstructed. |

### Additional interpretations

A few aspects of the brief do not fully specify how the business operates:

- The six-booking limit refers to bookings rather than completed lessons. I interpret this as a limit on reserved tutor time, meaning no-shows still count.
- The cancellation policy explicitly describes family cancellations but does not explain tutor-initiated cancellations. I assume families should not be charged when the tutor cancels.
- The spreadsheet represents each student as a separate lesson row, but the exam-pair records suggest that multiple students may share one teaching session. The data model may therefore need to distinguish between a lesson session and individual student bookings.
- The spreadsheet does not contain modification history or the identity of the person making changes. This information cannot be reliably reconstructed from the existing export.

These assumptions will guide the initial implementation. Where the available data is insufficient to determine what actually happened, the system should flag the record for review rather than silently infer or change its meaning.

# Phase 2: Choose what to build

## 1. Candidate Features

1. **Daily Schedule View:** Display lessons by date, time, tutor, student, room, and status.
2. **Booking Management:** Create, update, and cancel lesson bookings.
3. **Schedule Validation:** Identify tutor conflicts, room conflicts, closed-day bookings, and tutor workload violations.
4. **Cancellation Management:** Handle free cancellations, late cancellations, and no-shows.
5. **Schedule Change History:** Track previous booking values, timestamps, and responsible users.
6. **Spreadsheet Import:** Import existing records and identify duplicates, missing information, and inconsistent data.

## 2. Selected Feature: Daily Schedule View

I would prioritize the Daily Schedule View because it directly addresses the owner's most explicit request: being able to open the laptop and immediately see today's schedule without navigating through a spreadsheet.

The initial implementation will include:

- Display lessons for a selected date, defaulting to today.
- Show lesson time, duration, student, tutor, subject, and room.
- Display booking statuses, including booked, cancelled, and no-show.
- Organize lessons chronologically.
- Highlight potential scheduling conflicts and business rule violations.

The dashboard will be read-only. It will provide visibility into the existing schedule without attempting to replace the complete booking workflow.

## 3. Why This Feature?

- **Immediate business value:** The owner and receptionist can quickly understand the day's schedule.
- **Small implementation scope:** The existing spreadsheet already contains most of the information needed.
- **Reduced operational overhead:** Users no longer need to manually inspect multiple spreadsheet rows.
- **Future extensibility:** The structured data and API can later support booking management, cancellation workflows, and schedule validation.

## 4. What I Am Choosing to Leave Broken

- Mai can still create conflicting bookings through the existing spreadsheet.
- Tutor workload limits are not enforced when creating bookings.
- Cancellation and no-show workflows remain manual.
- Schedule modifications and post-cutoff approvals are not implemented.
- Historical inconsistencies are highlighted but not automatically corrected.
- WhatsApp messages are not synchronized with the dashboard.
- Full booking audit history is not available.

# Phase 3: Design and build

## 1. Implemented functionality

- Display lessons for a selected date in chronological order.
- Default to 2026-03-04 when the dashboard is opened.
- Allow the user to change the date without reloading the entire page.
- Display lesson details, including calculated end time.
- Distinguish between booked, cancelled, and no-show lessons.
- Identify overlapping tutor, student, and room bookings.
- Display summary counts for total lessons, booked lessons, cancelled/no-show lessons, and lessons with warnings.

## 2. Data model

The implementation uses three main entities: `Tutor`, `Lesson`, and `LessonEvent`.

### Tutor

Stores tutor information:

| Field | Description |
|---|---|
| tutor_id | Primary key |
| tutor_name | Tutor's name |
| subject | Subject taught |
| phone | Contact number |

### Lesson

Represents a student's booking with a tutor.

| Field | Description |
|---|---|
| lesson_id | Primary key |
| lesson_date | Scheduled date |
| start_time | Starting time |
| duration_min | Lesson duration in minutes |
| student_name | Student's name |
| tutor_id | Foreign key referencing Tutor |
| room | Assigned room |
| status | booked, cancelled, or no_show |
| cancelled_at | Timestamp when the lesson was cancelled |
| note | Additional information |

The end time is derived from `start_time + duration_min` rather than stored separately. This avoids maintaining two values that could become inconsistent.

### LessonEvent

This table is implemented to stores the history of changes and notifications associated with a lesson. For newly created data, it will follow the logic listed in this part.

| Field | Description |
|---|---|
| event_id | Primary key |
| lesson_id | Foreign key referencing Lesson |
| event_type | Type of event |
| occurred_at | Timestamp of the event |
| actor | Person or system responsible for the event |
| previous_data | Previous lesson data, if applicable |
| new_data | New lesson data, if applicable |
| related_event_id | Optional reference to a related event |

Supported event types include `CREATED`, `TUTOR_NOTIFIED`, `MOVED`, `CANCELLED`, and `NO_SHOW_MARKED`.

### Representing cancellation and movement after tutor notification

The `Lesson` record represents the current state of a booking, while `LessonEvent` preserves its change history.

For example, when a lesson is moved after the tutor has already been notified:

1. The existing `Lesson` record is updated with the new date, time, or room.
2. A `MOVED` event is added to `LessonEvent`, recording the previous and new values.
3. A new `TUTOR_NOTIFIED` event can record that the tutor was informed of the change.

Similarly, when a booking is cancelled:

1. The lesson's status becomes `cancelled`.
2. `cancelled_at` records when the cancellation occurred.
3. A `CANCELLED` event records the cancellation in the history.

Previous event records are retained rather than overwritten. This allows the system to distinguish the current booking state from what happened previously.

## 3. Database constraints vs. application-level rules

I separated data integrity constraints from scheduling rules.

### Database-enforced constraints

The database enforces rules that should always hold for individual records and their relationships:

| Rule | Implementation | Reason |
|---|---|---|
| Every lesson must reference an existing tutor | Foreign key constraint | Prevents lessons from referencing nonexistent tutors |
| Lesson duration must be positive | CHECK constraint | Prevents invalid durations |
| Lesson status must be valid | CHECK constraint | Restricts status to booked, cancelled, or no_show |
| A cancelled lesson must have a cancellation timestamp | CHECK constraint | Keeps cancellation state consistent |
| A non-cancelled lesson must not have a cancellation timestamp | CHECK constraint | Prevents inconsistent cancellation data |
| Event types must be valid | CHECK constraint | Restricts event types to supported values |
| Event records must reference an existing lesson | Foreign key constraint | Maintains event-to-lesson relationships |

These constraints protect the stored data regardless of which application component writes to the database.

### Application-level scheduling rules

Scheduling rules involving multiple lessons are handled in application code.

The daily schedule service calculates each lesson's start and end time, then compares overlapping time intervals.

Two lessons overlap when:

`first_start < second_end AND second_start < first_end`

For overlapping lessons, the service checks whether they share:

- The same tutor.
- The same student.
- The same room.

Cancelled lessons are excluded from conflict detection because their slots are released. No-show lessons remain included because the scheduled time is still considered occupied.

These checks are implemented in application code rather than database constraints because they involve comparing multiple records and their time intervals. They are also used to identify existing scheduling issues rather than reject or modify historical records.

The current feature detects overlapping tutor, student, and room bookings. Rules such as the six-booking daily limit, closed-day authorization, and cancellation notice policy are not enforced by this read-only feature because it does not create or modify bookings.

## 4. API Design

The application uses FastAPI to expose the schedule data.

### Daily schedule API

**Endpoint:** `GET /api/schedule?date=YYYY-MM-DD`

**Purpose:** Retrieve all lessons for a selected date.

**Example request:**

`GET /api/schedule?date=2026-03-10`

**Example response:**

```json
{
  "date": "2026-03-10",
  "total_lessons": 2,
  "lessons": [
    {
      "lesson_id": "L033",
      "date": "2026-03-10",
      "start_time": "09:00",
      "end_time": "10:00",
      "duration_min": 60,
      "student_name": "Le Minh Chau",
      "tutor_id": "T1",
      "tutor_name": "Ngoc Anh",
      "subject": "Maths",
      "room": "R1",
      "status": "booked",
      "note": null,
      "warnings": [
        "Tutor conflict with L034"
      ]
    },
    {
      "lesson_id": "L034",
      "date": "2026-03-10",
      "start_time": "09:00",
      "end_time": "10:00",
      "duration_min": 60,
      "student_name": "Tran Bao Long",
      "tutor_id": "T1",
      "tutor_name": "Ngoc Anh",
      "subject": "Maths",
      "room": "R2",
      "status": "booked",
      "note": null,
      "warnings": [
        "Tutor conflict with L033"
      ]
    }
  ]
}
```

The response contains the calculated end time and any scheduling warnings, so the frontend does not need to independently implement scheduling calculations.

### Dashboard routes

| Endpoint | Purpose |
|---|---|
| `GET /` | Render the dashboard using 2026-03-04 by default |
| `GET /dashboard` | Render the dashboard, optionally with a selected date |
| `GET /dashboard/schedule?target_date=YYYY-MM-DD` | Return the schedule HTML fragment when the selected date changes |

The dashboard uses Jinja2 for server-side rendering, Bootstrap 5 for styling, and HTMX to update the schedule content when the date picker changes.

### Rejected endpoint

I considered implementing:

`POST /api/lessons`

This endpoint would create a new booking and require request validation for tutor availability, student availability, room availability, daily workload limits, and closed-day rules.

I rejected it because booking management is outside the scope of the selected Daily Schedule View feature. Implementing it would introduce additional write operations and validation workflows that are not necessary to deliver the read-only dashboard.

## 5. Implementation and Observations

### Technology stack

| Component | Technology |
|---|---|
| Backend framework | FastAPI |
| Database | SQLite |
| ORM | SQLAlchemy |
| Frontend templates | Jinja2 |
| UI framework | Bootstrap 5 |
| Dynamic page updates | HTMX |

The implementation separates database models, repositories, services, and API routes:

- **Models:** Define the database entities and relationships.
- **Repositories:** Retrieve lessons and their associated tutors.
- **Services:** Calculate lesson end times and identify scheduling conflicts.
- **API routes:** Expose schedule data as JSON.
- **Templates:** Render the dashboard and its schedule content.

### Observed results

The application was tested using the imported seed data.

For March 04, 2026, the dashboard displayed six lessons in chronological order.

The application correctly identified the overlapping bookings between L007 and L008: Both lessons were assigned to the same student (Le Minh Chau)

Both lessons were displayed with student conflict warnings.

For L009 and L010, the dashboard also noted that these students are part of an exam pair with half price, based on the note column of the seed data.

The date picker was also tested to verify that changing the selected date updated the schedule content without reloading the entire page.

The implementation therefore demonstrates the selected feature using the existing dataset while preserving the distinction between current booking information and historical events.