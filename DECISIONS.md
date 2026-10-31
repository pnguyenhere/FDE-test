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