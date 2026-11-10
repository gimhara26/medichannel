
-- =========================================================
-- MEDICHANNEL DATABASE VALIDATION TESTS
-- Database: medichannel_db
-- Total Tables: 14
-- All tests are READ-ONLY
-- =========================================================


-- TEST 1: Count records in all 14 tables

SELECT 'users' AS table_name, COUNT(*) AS total FROM users
UNION ALL SELECT 'patients', COUNT(*) FROM patients
UNION ALL SELECT 'specialisations', COUNT(*) FROM specialisations
UNION ALL SELECT 'doctors', COUNT(*) FROM doctors
UNION ALL SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'consultations', COUNT(*) FROM consultations
UNION ALL SELECT 'chat_messages', COUNT(*) FROM chat_messages
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'feedback', COUNT(*) FROM feedback
UNION ALL SELECT 'notices', COUNT(*) FROM notices
UNION ALL SELECT 'audit_logs', COUNT(*) FROM audit_logs
ORDER BY table_name;


-- TEST 2: Check duplicate appointment numbers
-- Expected: zero rows

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
WHERE appointment_status IN (
                             'BOOKED',
                             'ARRIVED',
                             'IN_CONSULTATION'
    )
GROUP BY session_id, patient_id
HAVING COUNT(*) > 1;


-- TEST 4: Check invalid session room references
-- Expected: zero rows

SELECT
    s.id AS session_id,
    s.room_id
FROM sessions s
         LEFT JOIN rooms r
                   ON s.room_id = r.id
WHERE r.id IS NULL;


-- TEST 5: Check cancelled appointment timestamps
-- Expected: zero rows

SELECT
    id,
    appointment_status,
    cancelled_at
FROM appointments
WHERE
    (appointment_status = 'CANCELLED' AND cancelled_at IS NULL)
   OR
    (appointment_status <> 'CANCELLED' AND cancelled_at IS NOT NULL);


-- TEST 6: Check invalid session time ranges
-- Expected: zero rows

SELECT
    id,
    start_time,
    end_time
FROM sessions
WHERE end_time <= start_time;


-- TEST 7: Check invalid consultation time ranges
-- Expected: zero rows

SELECT
    id,
    started_at,
    completed_at
FROM consultations
WHERE started_at IS NOT NULL
  AND completed_at IS NOT NULL
  AND completed_at < started_at;


-- TEST 8: Check invalid feedback ratings
-- Expected: zero rows

SELECT
    id,
    rating
FROM feedback
WHERE rating < 1
   OR rating > 5;


-- TEST 9: Check invalid payment records
-- Expected: zero rows

SELECT
    id,
    payment_status,
    payment_method,
    paid_at
FROM payments
WHERE
    (payment_status = 'PENDING' AND paid_at IS NOT NULL)
   OR
    (payment_status = 'PAID'
        AND (paid_at IS NULL OR payment_method IS NULL));


-- TEST 10: Check invalid appointment numbers
-- Expected: zero rows

SELECT
    id,
    appointment_number
FROM appointments
WHERE appointment_number < 1;


-- =========================================================
-- END OF MEDICHANNEL DATABASE VALIDATION
-- =========================================================
