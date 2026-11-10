-- =========================================================
-- MediChannel Hospital Channelling System
-- PostgreSQL Database Schema
-- Database: medichannel_db
-- Total Tables: 14
-- Timezone: Asia/Colombo
-- =========================================================

BEGIN;

SET TIME ZONE 'Asia/Colombo';

-- 1. USERS
CREATE TABLE users (
                       id BIGSERIAL PRIMARY KEY,
                       full_name VARCHAR(150) NOT NULL,
                       email_encrypted TEXT NOT NULL,
                       email_lookup_hash CHAR(64) NOT NULL UNIQUE,
                       password_hash TEXT NOT NULL,
                       role VARCHAR(20) NOT NULL
                           CHECK (role IN ('ADMIN', 'MANAGER', 'DOCTOR', 'CUSTOMER')),
                       is_active BOOLEAN NOT NULL DEFAULT TRUE,
                       created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. PATIENTS
CREATE TABLE patients (
                          id BIGSERIAL PRIMARY KEY,
                          user_id BIGINT NOT NULL UNIQUE,
                          nic_encrypted TEXT,
                          nic_lookup_hash CHAR(64) UNIQUE,
                          date_of_birth DATE,
                          gender VARCHAR(20),
                          phone_encrypted TEXT,
                          address_encrypted TEXT,
                          created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                          CONSTRAINT fk_patients_user
                              FOREIGN KEY (user_id)
                                  REFERENCES users(id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT
);

-- 3. SPECIALISATIONS
CREATE TABLE specialisations (
                                 id BIGSERIAL PRIMARY KEY,
                                 name VARCHAR(100) NOT NULL UNIQUE,
                                 description TEXT,
                                 is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4. DOCTORS
CREATE TABLE doctors (
                         id BIGSERIAL PRIMARY KEY,
                         user_id BIGINT NOT NULL UNIQUE,
                         specialisation_id BIGINT NOT NULL,
                         qualification VARCHAR(200),
                         experience_years INTEGER
                             CHECK (experience_years >= 0),
                         consultation_fee NUMERIC(12,2) NOT NULL
                             CHECK (consultation_fee >= 0),
                         is_active BOOLEAN NOT NULL DEFAULT TRUE,

                         CONSTRAINT fk_doctors_user
                             FOREIGN KEY (user_id)
                                 REFERENCES users(id)
                                 ON UPDATE CASCADE
                                 ON DELETE RESTRICT,

                         CONSTRAINT fk_doctors_specialisation
                             FOREIGN KEY (specialisation_id)
                                 REFERENCES specialisations(id)
                                 ON UPDATE CASCADE
                                 ON DELETE RESTRICT
);

CREATE INDEX idx_doctors_specialisation
    ON doctors(specialisation_id);

-- 5. ROOMS
CREATE TABLE rooms (
                       id BIGSERIAL PRIMARY KEY,
                       room_name VARCHAR(100) NOT NULL UNIQUE,
                       location VARCHAR(150),
                       is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 6. SESSIONS
CREATE TABLE sessions (
                          id BIGSERIAL PRIMARY KEY,
                          doctor_id BIGINT NOT NULL,
                          room_id BIGINT NOT NULL,
                          session_date DATE NOT NULL,
                          start_time TIME NOT NULL,
                          end_time TIME NOT NULL,
                          max_patients INTEGER NOT NULL
                              CHECK (max_patients > 0),
                          consultation_fee NUMERIC(12,2) NOT NULL
                              CHECK (consultation_fee >= 0),
                          status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED'
                              CHECK (status IN ('SCHEDULED', 'CANCELLED', 'COMPLETED')),
                          created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                          CONSTRAINT fk_sessions_doctor
                              FOREIGN KEY (doctor_id)
                                  REFERENCES doctors(id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,

                          CONSTRAINT fk_sessions_room
                              FOREIGN KEY (room_id)
                                  REFERENCES rooms(id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,

                          CONSTRAINT chk_session_time
                              CHECK (end_time > start_time),

                          CONSTRAINT uq_session_room_date_time
                              UNIQUE (room_id, session_date, start_time)
);

CREATE INDEX idx_sessions_doctor
    ON sessions(doctor_id);

CREATE INDEX idx_sessions_date
    ON sessions(session_date);

-- 7. APPOINTMENTS
CREATE TABLE appointments (
                              id BIGSERIAL PRIMARY KEY,
                              session_id BIGINT NOT NULL,
                              patient_id BIGINT NOT NULL,
                              appointment_number INTEGER NOT NULL
                                  CHECK (appointment_number >= 1),

                              appointment_status VARCHAR(20) NOT NULL DEFAULT 'BOOKED'
                                  CHECK (
                                      appointment_status IN (
                                                             'BOOKED',
                                                             'ARRIVED',
                                                             'IN_CONSULTATION',
                                                             'COMPLETED',
                                                             'CANCELLED',
                                                             'NO_SHOW'
                                          )
                                      ),

                              payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                                  CHECK (payment_status IN ('PENDING', 'PAID')),

                              payment_method VARCHAR(20)
                                  CHECK (payment_method IN ('CASH', 'CARD')),

                              booked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              arrived_at TIMESTAMPTZ,
                              cancelled_at TIMESTAMPTZ,

                              CONSTRAINT fk_appointments_session
                                  FOREIGN KEY (session_id)
                                      REFERENCES sessions(id)
                                      ON UPDATE CASCADE
                                      ON DELETE RESTRICT,

                              CONSTRAINT fk_appointments_patient
                                  FOREIGN KEY (patient_id)
                                      REFERENCES patients(id)
                                      ON UPDATE CASCADE
                                      ON DELETE RESTRICT,

                              CONSTRAINT uq_appointment_session_number
                                  UNIQUE (session_id, appointment_number),

                              CONSTRAINT uq_appointment_id_patient
                                  UNIQUE (id, patient_id)
);

CREATE INDEX idx_appointments_session
    ON appointments(session_id);

CREATE INDEX idx_appointments_patient
    ON appointments(patient_id);

CREATE INDEX idx_appointments_status
    ON appointments(appointment_status);

CREATE UNIQUE INDEX uq_active_patient_session
    ON appointments(session_id, patient_id)
    WHERE appointment_status IN (
        'BOOKED',
        'ARRIVED',
        'IN_CONSULTATION'
    );

-- 8. PAYMENTS
CREATE TABLE payments (
                          id BIGSERIAL PRIMARY KEY,
                          appointment_id BIGINT NOT NULL UNIQUE,
                          amount NUMERIC(12,2) NOT NULL
                              CHECK (amount >= 0),

                          payment_method VARCHAR(20)
                              CHECK (payment_method IN ('CASH', 'CARD')),

                          payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                              CHECK (payment_status IN ('PENDING', 'PAID')),

                          paid_at TIMESTAMPTZ,
                          recorded_by BIGINT,
                          created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                          CONSTRAINT fk_payments_appointment
                              FOREIGN KEY (appointment_id)
                                  REFERENCES appointments(id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,

                          CONSTRAINT fk_payments_recorder
                              FOREIGN KEY (recorded_by)
                                  REFERENCES users(id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,

                          CONSTRAINT chk_payment_details CHECK (
                              (
                                  payment_status = 'PENDING'
                                      AND paid_at IS NULL
                                  )
                                  OR
                              (
                                  payment_status = 'PAID'
                                      AND paid_at IS NOT NULL
                                      AND payment_method IS NOT NULL
                                  )
                              )
);

CREATE INDEX idx_payments_status
    ON payments(payment_status);

CREATE INDEX idx_payments_created
    ON payments(created_at DESC);

CREATE INDEX idx_payments_recorder
    ON payments(recorded_by);

-- 9. CONSULTATIONS
CREATE TABLE consultations (
                               id BIGSERIAL PRIMARY KEY,
                               appointment_id BIGINT NOT NULL UNIQUE,
                               consultation_notes_encrypted TEXT,
                               prescription_encrypted TEXT,
                               started_at TIMESTAMPTZ,
                               completed_at TIMESTAMPTZ,

                               CONSTRAINT fk_consultations_appointment
                                   FOREIGN KEY (appointment_id)
                                       REFERENCES appointments(id)
                                       ON UPDATE CASCADE
                                       ON DELETE RESTRICT,

                               CONSTRAINT chk_consultation_time
                                   CHECK (
                                       completed_at IS NULL
                                           OR started_at IS NULL
                                           OR completed_at >= started_at
                                       )
);

-- 10. CHAT MESSAGES
CREATE TABLE chat_messages (
                               id BIGSERIAL PRIMARY KEY,
                               consultation_id BIGINT NOT NULL,
                               sender_user_id BIGINT NOT NULL,
                               message_encrypted TEXT NOT NULL,
                               sent_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                               CONSTRAINT fk_chat_consultation
                                   FOREIGN KEY (consultation_id)
                                       REFERENCES consultations(id)
                                       ON UPDATE CASCADE
                                       ON DELETE RESTRICT,

                               CONSTRAINT fk_chat_sender
                                   FOREIGN KEY (sender_user_id)
                                       REFERENCES users(id)
                                       ON UPDATE CASCADE
                                       ON DELETE RESTRICT
);

CREATE INDEX idx_chat_consultation
    ON chat_messages(consultation_id, sent_at);

-- 11. NOTIFICATIONS
CREATE TABLE notifications (
                               id BIGSERIAL PRIMARY KEY,
                               user_id BIGINT NOT NULL,
                               title VARCHAR(200) NOT NULL,
                               message TEXT NOT NULL,
                               is_read BOOLEAN NOT NULL DEFAULT FALSE,
                               created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                               CONSTRAINT fk_notifications_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES users(id)
                                       ON UPDATE CASCADE
                                       ON DELETE RESTRICT
);

CREATE INDEX idx_notifications_user
    ON notifications(user_id, created_at DESC);

-- 12. FEEDBACK
CREATE TABLE feedback (
                          id BIGSERIAL PRIMARY KEY,
                          appointment_id BIGINT NOT NULL,
                          patient_id BIGINT NOT NULL,
                          rating INTEGER NOT NULL
                              CHECK (rating BETWEEN 1 AND 5),
                          comment TEXT,
                          created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                          CONSTRAINT fk_feedback_appointment_patient
                              FOREIGN KEY (appointment_id, patient_id)
                                  REFERENCES appointments(id, patient_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,

                          CONSTRAINT uq_feedback_appointment
                              UNIQUE (appointment_id)
);

-- 13. NOTICES
CREATE TABLE notices (
                         id BIGSERIAL PRIMARY KEY,
                         title VARCHAR(200) NOT NULL,
                         content TEXT NOT NULL,
                         created_by BIGINT NOT NULL,
                         published_at TIMESTAMPTZ,
                         expires_at TIMESTAMPTZ,
                         is_active BOOLEAN NOT NULL DEFAULT TRUE,

                         CONSTRAINT fk_notices_creator
                             FOREIGN KEY (created_by)
                                 REFERENCES users(id)
                                 ON UPDATE CASCADE
                                 ON DELETE RESTRICT,

                         CONSTRAINT chk_notice_expiry
                             CHECK (
                                 expires_at IS NULL
                                     OR published_at IS NULL
                                     OR expires_at > published_at
                                 )
);

-- 14. AUDIT LOGS
CREATE TABLE audit_logs (
                            id BIGSERIAL PRIMARY KEY,
                            actor_user_id BIGINT,
                            action VARCHAR(100) NOT NULL,
                            entity_type VARCHAR(100),
                            entity_id BIGINT,
                            created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                            CONSTRAINT fk_audit_actor
                                FOREIGN KEY (actor_user_id)
                                    REFERENCES users(id)
                                    ON UPDATE CASCADE
                                    ON DELETE RESTRICT
);

CREATE INDEX idx_audit_actor
    ON audit_logs(actor_user_id);

CREATE INDEX idx_audit_created
    ON audit_logs(created_at DESC);

COMMIT;