-- MediChannel initial PostgreSQL schema.
-- All timestamps are stored as timestamptz and application business time is Asia/Colombo.
-- Sensitive values are stored as ciphertext by the application; *_lookup_hash columns
-- support equality lookup without decrypting the protected value.

CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email_ciphertext TEXT NOT NULL,
  email_lookup_hash CHAR(64) NOT NULL UNIQUE,
  password_hash VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('CUSTOMER','DOCTOR','MANAGER','ADMIN')),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  failed_login_attempts INTEGER NOT NULL DEFAULT 0 CHECK (failed_login_attempts >= 0),
  locked_until TIMESTAMPTZ,
  password_change_required BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patients (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE REFERENCES users(id),
  full_name_ciphertext TEXT NOT NULL,
  nic_ciphertext TEXT NOT NULL,
  nic_lookup_hash CHAR(64) NOT NULL UNIQUE,
  date_of_birth_ciphertext TEXT NOT NULL,
  gender VARCHAR(30),
  phone_ciphertext TEXT NOT NULL,
  address_ciphertext TEXT NOT NULL
);

CREATE TABLE specialisations (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
  description TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE doctors (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE REFERENCES users(id),
  specialisation_id BIGINT NOT NULL REFERENCES specialisations(id),
  full_name_ciphertext TEXT NOT NULL,
  slmc_registration_number VARCHAR(50) NOT NULL UNIQUE,
  qualifications TEXT NOT NULL,
  bio TEXT,
  default_fee NUMERIC(12,2) NOT NULL CHECK (default_fee >= 0),
  active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE rooms (
  id BIGSERIAL PRIMARY KEY,
  room_name VARCHAR(80) NOT NULL UNIQUE,
  location_description TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE sessions (
  id BIGSERIAL PRIMARY KEY,
  doctor_id BIGINT NOT NULL REFERENCES doctors(id),
  room_id BIGINT REFERENCES rooms(id),
  session_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  session_type VARCHAR(20) NOT NULL CHECK (session_type IN ('PHYSICAL','ONLINE')),
  max_patients INTEGER NOT NULL CHECK (max_patients BETWEEN 1 AND 60),
  minutes_per_patient INTEGER NOT NULL CHECK (minutes_per_patient BETWEEN 5 AND 30),
  fee NUMERIC(12,2) NOT NULL CHECK (fee >= 0),
  delay_minutes INTEGER NOT NULL DEFAULT 0 CHECK (delay_minutes >= 0),
  status VARCHAR(20) NOT NULL CHECK (status IN ('SCHEDULED','OPEN','IN_PROGRESS','COMPLETED','CANCELLED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (end_time > start_time),
  CHECK ((session_type = 'PHYSICAL' AND room_id IS NOT NULL) OR (session_type = 'ONLINE' AND room_id IS NULL))
);

CREATE TABLE appointments (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT NOT NULL REFERENCES sessions(id),
  patient_id BIGINT NOT NULL REFERENCES patients(id),
  appointment_number INTEGER NOT NULL CHECK (appointment_number >= 1),
  appointment_type VARCHAR(20) NOT NULL CHECK (appointment_type IN ('PHYSICAL','ONLINE')),
  reason_ciphertext TEXT NOT NULL,
  booking_reference VARCHAR(40) NOT NULL UNIQUE,
  status VARCHAR(30) NOT NULL CHECK (status IN ('BOOKED','ARRIVED','IN_CONSULTATION','COMPLETED','NO_SHOW','CANCELLED')),
  payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING','PAID')),
  payment_method VARCHAR(20) CHECK (payment_method IN ('CASH','CARD')),
  checked_in_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cancelled_at TIMESTAMPTZ,
  UNIQUE (session_id, appointment_number)
);
CREATE UNIQUE INDEX uq_patient_active_session
  ON appointments(session_id, patient_id)
  WHERE status IN ('BOOKED','ARRIVED','IN_CONSULTATION');

CREATE TABLE consultations (
  id BIGSERIAL PRIMARY KEY,
  appointment_id BIGINT NOT NULL UNIQUE REFERENCES appointments(id),
  diagnosis_ciphertext TEXT,
  advice_ciphertext TEXT,
  prescription_ciphertext TEXT,
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE chat_messages (
  id BIGSERIAL PRIMARY KEY,
  consultation_id BIGINT NOT NULL REFERENCES consultations(id),
  sender_user_id BIGINT NOT NULL REFERENCES users(id),
  message_ciphertext TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  notification_type VARCHAR(40) NOT NULL,
  title VARCHAR(160) NOT NULL,
  body TEXT NOT NULL,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE feedback (
  id BIGSERIAL PRIMARY KEY,
  appointment_id BIGINT NOT NULL UNIQUE REFERENCES appointments(id),
  patient_id BIGINT NOT NULL REFERENCES patients(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  visible BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notices (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(180) NOT NULL,
  body TEXT NOT NULL,
  published BOOLEAN NOT NULL DEFAULT FALSE,
  published_at TIMESTAMPTZ,
  created_by BIGINT NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  actor_user_id BIGINT REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(80),
  target_id VARCHAR(80),
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_date_status ON sessions(session_date, status);
CREATE INDEX idx_appointments_session_status ON appointments(session_id, status);
CREATE INDEX idx_appointments_patient_created ON appointments(patient_id, created_at DESC);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_chat_consultation_created ON chat_messages(consultation_id, created_at);

-- IMPORTANT: BR-03 appointment allocation must be implemented transactionally in the
-- Spring service (lock the session row / use an atomic allocator). The UNIQUE constraint
-- is a final safety net, not a complete concurrency strategy.
-- IMPORTANT: enforce doctor and room time-overlap rules in the service and, where possible,
-- PostgreSQL exclusion constraints using a suitable migration strategy.
