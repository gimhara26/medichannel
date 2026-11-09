-- MediChannel database validation tests
-- Safe, read-only checks. No records are modified.

-- TEST 1: Total records in all 13 tables

SELECT 'users' AS table_name, COUNT(*) AS total FROM users
UNION ALL SELECT 'patients', COUNT(*) FROM patients
UNION ALL SELECT 'specialisations', COUNT(*) FROM specialisations
UNION ALL SELECT 'doctors', COUNT(*) FROM doctors
UNION ALL SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'consultations', COUNT(*) FROM consultations
UNION ALL SELECT 'chat_messages', COUNT(*) FROM chat_messages
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'feedback', COUNT(*) FROM feedback
UNION ALL SELECT 'notices', COUNT(*) FROM notices
UNION ALL SELECT 'audit_logs', COUNT(*) FROM audit_logs
ORDER BY table_name;


-- TEST 2: Check appointment number uniqueness

SELECT
    session_id,
    appointment_number,
    COUNT(*) AS duplicate_count
FROM appointments
GROUP BY session_id, appointment_number
HAVING COUNT(*) > 1;


-- TEST 3: Check duplicate active appointments
-- Expected: zero rows

SELECT
    session_id,
    patient_id,
    COUNT(*) AS duplicate_count
FROM appointments
WHERE status IN ('BOOKED', 'ARRIVED', 'IN_CONSULTATION')
GROUP BY session_id, patient_id
HAVING COUNT(*) > 1;


-- TEST 4: Check invalid session room combinations
-- Expected: zero rows

SELECT id, session_type, room_id
FROM sessions
WHERE
    (session_type = 'PHYSICAL' AND room_id IS NULL)
   OR
    (session_type = 'ONLINE' AND room_id IS NOT NULL);


-- TEST 5: Check cancelled appointment timestamps
-- Expected: zero rows

SELECT id, status, cancelled_at
FROM appointments
WHERE
    (status = 'CANCELLED' AND cancelled_at IS NULL)
   OR
    (status <> 'CANCELLED' AND cancelled_at IS NOT NULL);


-- TEST 6: Check invalid session time ranges
-- Expected: zero rows

SELECT id, start_time, end_time
FROM sessions
WHERE end_time <= start_time;


-- TEST 7: Check consultations with invalid time ranges
-- Expected: zero rows

SELECT id, started_at, ended_at
FROM consultations
WHERE started_at IS NOT NULL
  AND ended_at IS NOT NULL
  AND ended_at < started_at;


-- TEST 8: Check feedback rating values
-- Expected: zero rows

SELECT id, rating
FROM feedback
WHERE rating < 1 OR rating > 5;