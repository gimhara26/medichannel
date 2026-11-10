-- =========================================================
-- MediChannel Hospital Channelling System
-- Demonstration Seed Data
-- Total Records: 44
-- Run after schema.sql
-- =========================================================

BEGIN;

-- 1. USERS (6)
INSERT INTO users (
    id, full_name, email_encrypted, email_lookup_hash,
    password_hash, role, is_active
)
VALUES
    (1, 'System Administrator', 'DEMO_ENCRYPTED_ADMIN_EMAIL',
     md5('admin@example.com') || md5('admin@example.com'),
     'DEMO_BCRYPT_HASH_NOT_FOR_LOGIN', 'ADMIN', TRUE),

    (2, 'Hospital Manager', 'DEMO_ENCRYPTED_MANAGER_EMAIL',
     md5('manager@example.com') || md5('manager@example.com'),
     'DEMO_BCRYPT_HASH_NOT_FOR_LOGIN', 'MANAGER', TRUE),

    (3, 'Dr. Nimal Perera', 'DEMO_ENCRYPTED_DOCTOR1_EMAIL',
     md5('doctor1@example.com') || md5('doctor1@example.com'),
     'DEMO_BCRYPT_HASH_NOT_FOR_LOGIN', 'DOCTOR', TRUE),

    (4, 'Dr. Amali Fernando', 'DEMO_ENCRYPTED_DOCTOR2_EMAIL',
     md5('doctor2@example.com') || md5('doctor2@example.com'),
     'DEMO_BCRYPT_HASH_NOT_FOR_LOGIN', 'DOCTOR', TRUE),

    (5, 'Kamal Silva', 'DEMO_ENCRYPTED_PATIENT1_EMAIL',
     md5('patient1@example.com') || md5('patient1@example.com'),
     'DEMO_BCRYPT_HASH_NOT_FOR_LOGIN', 'CUSTOMER', TRUE),

    (6, 'Nadeesha Perera', 'DEMO_ENCRYPTED_PATIENT2_EMAIL',
     md5('patient2@example.com') || md5('patient2@example.com'),
     'DEMO_BCRYPT_HASH_NOT_FOR_LOGIN', 'CUSTOMER', TRUE);


-- 2. PATIENTS (2)
INSERT INTO patients (
    id, user_id, nic_encrypted, nic_lookup_hash,
    date_of_birth, gender, phone_encrypted, address_encrypted
)
VALUES
    (1, 5, 'DEMO_ENCRYPTED_NIC_1',
     md5('DEMO_NIC_1') || md5('DEMO_NIC_1'),
     '1998-05-12', 'MALE',
     'DEMO_ENCRYPTED_PHONE_1',
     'DEMO_ENCRYPTED_ADDRESS_1'),

    (2, 6, 'DEMO_ENCRYPTED_NIC_2',
     md5('DEMO_NIC_2') || md5('DEMO_NIC_2'),
     '2000-08-20', 'FEMALE',
     'DEMO_ENCRYPTED_PHONE_2',
     'DEMO_ENCRYPTED_ADDRESS_2');


-- 3. SPECIALISATIONS (4)
INSERT INTO specialisations (
    id, name, description, is_active
)
VALUES
    (1, 'Cardiology', 'Heart and cardiovascular care', TRUE),
    (2, 'Dermatology', 'Skin and related conditions', TRUE),
    (3, 'Paediatrics', 'Medical care for children', TRUE),
    (4, 'Neurology', 'Nervous system and brain care', TRUE);


-- 4. DOCTORS (2)
INSERT INTO doctors (
    id, user_id, specialisation_id,
    qualification, experience_years,
    consultation_fee, is_active
)
VALUES
    (1, 3, 1, 'MBBS, MD Cardiology', 12, 2500.00, TRUE),
    (2, 4, 2, 'MBBS, MD Dermatology', 8, 3000.00, TRUE);


-- 5. ROOMS (2)
INSERT INTO rooms (
    id, room_name, location, is_active
)
VALUES
    (1, 'Consultation Room 01', 'Ground Floor', TRUE),
    (2, 'Consultation Room 02', 'First Floor', TRUE);


-- 6. SESSIONS (2)
INSERT INTO sessions (
    id, doctor_id, room_id, session_date,
    start_time, end_time, max_patients,
    consultation_fee, status
)
VALUES
    (1, 1, 1, CURRENT_DATE,
     '08:00:00', '17:00:00', 10,
     2500.00, 'SCHEDULED'),

    (2, 2, 2, CURRENT_DATE - 1,
     '08:00:00', '17:00:00', 10,
     3000.00, 'COMPLETED');


-- 7. APPOINTMENTS (6)
INSERT INTO appointments (
    id, session_id, patient_id, appointment_number,
    appointment_status, payment_status, payment_method,
    booked_at, arrived_at, cancelled_at
)
VALUES
-- Appointment 1: Booked
(1, 1, 1, 1, 'BOOKED', 'PENDING', NULL,
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 NULL, NULL),

-- Appointment 2: Arrived
(2, 1, 2, 2, 'ARRIVED', 'PAID', 'CASH',
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 CURRENT_TIMESTAMP - INTERVAL '1 hour',
 NULL),

-- Appointment 3: Completed
(3, 1, 1, 3, 'COMPLETED', 'PAID', 'CARD',
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 CURRENT_TIMESTAMP - INTERVAL '45 minutes',
 NULL),

-- Appointment 4: Completed
(4, 1, 1, 4, 'COMPLETED', 'PAID', 'CASH',
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 CURRENT_TIMESTAMP - INTERVAL '3 hours',
 NULL),

-- Appointment 5: No show
(5, 2, 2, 1, 'NO_SHOW', 'PENDING', NULL,
 CURRENT_TIMESTAMP - INTERVAL '3 days',
 NULL, NULL),

-- Appointment 6: Cancelled
(6, 2, 1, 2, 'CANCELLED', 'PENDING', NULL,
 CURRENT_TIMESTAMP - INTERVAL '3 days',
 NULL,
 CURRENT_TIMESTAMP - INTERVAL '2 days');


-- 8. PAYMENTS (6)
INSERT INTO payments (
    id, appointment_id, amount,
    payment_method, payment_status,
    paid_at, recorded_by
)
VALUES
    (1, 1, 2500.00, NULL, 'PENDING', NULL, 2),

    (2, 2, 2500.00, 'CASH', 'PAID',
     CURRENT_TIMESTAMP - INTERVAL '1 hour', 2),

    (3, 3, 2500.00, 'CARD', 'PAID',
     CURRENT_TIMESTAMP - INTERVAL '45 minutes', 2),

    (4, 4, 2500.00, 'CASH', 'PAID',
     CURRENT_TIMESTAMP - INTERVAL '2 hours', 2),

    (5, 5, 3000.00, NULL, 'PENDING', NULL, 2),

    (6, 6, 3000.00, NULL, 'PENDING', NULL, 2);


-- 9. CONSULTATIONS (2)
INSERT INTO consultations (
    id, appointment_id,
    consultation_notes_encrypted,
    prescription_encrypted,
    started_at, completed_at
)
VALUES
    (1, 3,
     'DEMO_ENCRYPTED_CONSULTATION_NOTES_1',
     'DEMO_ENCRYPTED_PRESCRIPTION_1',
     CURRENT_TIMESTAMP - INTERVAL '30 minutes',
     CURRENT_TIMESTAMP - INTERVAL '10 minutes'),

    (2, 4,
     'DEMO_ENCRYPTED_CONSULTATION_NOTES_2',
     'DEMO_ENCRYPTED_PRESCRIPTION_2',
     CURRENT_TIMESTAMP - INTERVAL '3 hours',
     CURRENT_TIMESTAMP - INTERVAL '2 hours');


-- 10. CHAT MESSAGES (3)
INSERT INTO chat_messages (
    id, consultation_id, sender_user_id,
    message_encrypted, sent_at
)
VALUES
    (1, 1, 5, 'DEMO_ENCRYPTED_MESSAGE_1',
     CURRENT_TIMESTAMP - INTERVAL '25 minutes'),

    (2, 1, 3, 'DEMO_ENCRYPTED_MESSAGE_2',
     CURRENT_TIMESTAMP - INTERVAL '20 minutes'),

    (3, 2, 5, 'DEMO_ENCRYPTED_MESSAGE_3',
     CURRENT_TIMESTAMP - INTERVAL '2 hours');


-- 11. NOTIFICATIONS (3)
INSERT INTO notifications (
    id, user_id, title, message, is_read
)
VALUES
    (1, 5, 'Appointment Confirmation',
     'Your appointment has been booked.', FALSE),

    (2, 6, 'Payment Reminder',
     'Please complete your appointment payment.', FALSE),

    (3, 3, 'New Appointment',
     'A new patient appointment has been registered.', TRUE);


-- 12. FEEDBACK (1)
INSERT INTO feedback (
    id, appointment_id, patient_id, rating, comment
)
VALUES
    (1, 4, 1, 5, 'Excellent consultation service.');


-- 13. NOTICES (2)
INSERT INTO notices (
    id, title, content, created_by,
    published_at, expires_at, is_active
)
VALUES
    (1, 'Hospital Notice',
     'Welcome to MediChannel Hospital.',
     2,
     CURRENT_TIMESTAMP - INTERVAL '1 day',
     CURRENT_TIMESTAMP + INTERVAL '30 days',
     TRUE),

    (2, 'Appointment Information',
     'Please arrive before your appointment time.',
     2,
     CURRENT_TIMESTAMP - INTERVAL '1 day',
     CURRENT_TIMESTAMP + INTERVAL '15 days',
     TRUE);


-- 14. AUDIT LOGS (3)
INSERT INTO audit_logs (
    id, actor_user_id, action, entity_type, entity_id
)
VALUES
    (1, 1, 'SYSTEM_INITIALIZED', 'SYSTEM', NULL),
    (2, 2, 'PAYMENT_RECORDED', 'PAYMENT', 2),
    (3, 2, 'NOTICE_CREATED', 'NOTICE', 1);


-- RESET GENERATED ID SEQUENCES
SELECT setval(pg_get_serial_sequence('users', 'id'),
              (SELECT MAX(id) FROM users), TRUE);

SELECT setval(pg_get_serial_sequence('patients', 'id'),
              (SELECT MAX(id) FROM patients), TRUE);

SELECT setval(pg_get_serial_sequence('specialisations', 'id'),
              (SELECT MAX(id) FROM specialisations), TRUE);

SELECT setval(pg_get_serial_sequence('doctors', 'id'),
              (SELECT MAX(id) FROM doctors), TRUE);

SELECT setval(pg_get_serial_sequence('rooms', 'id'),
              (SELECT MAX(id) FROM rooms), TRUE);

SELECT setval(pg_get_serial_sequence('sessions', 'id'),
              (SELECT MAX(id) FROM sessions), TRUE);

SELECT setval(pg_get_serial_sequence('appointments', 'id'),
              (SELECT MAX(id) FROM appointments), TRUE);

SELECT setval(pg_get_serial_sequence('payments', 'id'),
              (SELECT MAX(id) FROM payments), TRUE);

SELECT setval(pg_get_serial_sequence('consultations', 'id'),
              (SELECT MAX(id) FROM consultations), TRUE);

SELECT setval(pg_get_serial_sequence('chat_messages', 'id'),
              (SELECT MAX(id) FROM chat_messages), TRUE);

SELECT setval(pg_get_serial_sequence('notifications', 'id'),
              (SELECT MAX(id) FROM notifications), TRUE);

SELECT setval(pg_get_serial_sequence('feedback', 'id'),
              (SELECT MAX(id) FROM feedback), TRUE);

SELECT setval(pg_get_serial_sequence('notices', 'id'),
              (SELECT MAX(id) FROM notices), TRUE);

SELECT setval(pg_get_serial_sequence('audit_logs', 'id'),
              (SELECT MAX(id) FROM audit_logs), TRUE);

COMMIT;