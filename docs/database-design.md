# MediChannel – Database Design and Management

## 1. Introduction

The MediChannel system uses PostgreSQL as its relational database management system. The database stores and manages information required for hospital channelling, patient registration, doctor management, appointment booking, payments, consultations, notifications and feedback.

The database was designed with referential integrity, data consistency, security and maintainability in mind.

## 2. Database Technology

| Component | Technology |
|---|---|
| Database Management System | PostgreSQL |
| Database Administration Tool | pgAdmin |
| Database Name | medichannel_db |
| Database Timezone | Asia/Colombo |
| Database Design | Relational Database Model |
| SQL Script | database/schema.sql |

## 3. Database Tables

The database contains **14 relational tables**.

| No. | Table | Purpose |
|---|---|---|
| 1 | users | Stores user account information and roles |
| 2 | patients | Stores patient profile information |
| 3 | specialisations | Stores medical specialisations |
| 4 | doctors | Stores doctor information |
| 5 | rooms | Stores consultation room information |
| 6 | sessions | Stores doctor channelling sessions |
| 7 | appointments | Stores patient appointment bookings |
| 8 | payments | Stores appointment payment information |
| 9 | consultations | Stores consultation records |
| 10 | chat_messages | Stores consultation chat messages |
| 11 | notifications | Stores user notifications |
| 12 | feedback | Stores patient feedback |
| 13 | notices | Stores hospital notices |
| 14 | audit_logs | Stores system audit activities |

## 4. Entity Relationship Diagram

The database entity relationship diagram is available at:

`database/erd/medichannel-erd.md`

The ERD illustrates the relationships between users, patients, doctors, specialisations, sessions, appointments, payments, consultations and other database entities.

## 5. Primary Keys and Foreign Keys

Each database table has a primary key to uniquely identify its records.

Foreign keys establish relationships between related tables and maintain referential integrity.

Examples:

- Patients reference users.
- Doctors reference users and specialisations.
- Sessions reference doctors and rooms.
- Appointments reference patients and sessions.
- Payments reference appointments and users who record payments.
- Consultations reference appointments.
- Chat messages reference consultations and users.
- Feedback references appointments and patients.
- Notifications reference users.
- Notices reference their creators.
- Audit logs reference the users who perform activities.

## 6. Database Constraints

The database uses constraints to maintain data accuracy and consistency.

Implemented constraints include:

- PRIMARY KEY constraints.
- FOREIGN KEY constraints.
- UNIQUE constraints.
- NOT NULL constraints.
- CHECK constraints.

Examples of validation rules:

- Appointment numbers must be greater than or equal to 1.
- Feedback ratings must be between 1 and 5.
- Session end time must be later than start time.
- Doctor consultation fees cannot be negative.
- User roles must be CUSTOMER, DOCTOR, MANAGER or ADMIN.
- Appointment status must be one of the supported statuses.
- Payment status must be PENDING or PAID.
- A patient cannot have multiple active appointments in the same session.
- A paid payment must have a payment date and payment method.

## 7. Database Indexes

Indexes were created to improve query performance.

Examples include:

- Appointment indexes for patient, session and appointment status searches.
- Doctor indexes for specialisation searches.
- Session indexes for date and doctor searches.
- Payment indexes for payment status, creation date and payment recorder searches.
- Notification indexes for user notification retrieval.
- Audit log indexes for actor and creation date searches.
- Chat message indexes for consultation message retrieval.

Unique indexes also enforce important business rules, including preventing multiple active appointments for the same patient in the same session.

## 8. Timezone Management

The database timezone is configured as Asia/Colombo.

Timestamp fields use PostgreSQL TIMESTAMPTZ where appropriate to support timezone-aware date and time storage.

## 9. Seed Data

Fictional seed data was inserted to test the database structure and relationships.

| Table | Records |
|---|---:|
| users | 6 |
| patients | 2 |
| specialisations | 4 |
| doctors | 2 |
| rooms | 2 |
| sessions | 2 |
| appointments | 6 |
| payments | 6 |
| consultations | 2 |
| chat_messages | 3 |
| notifications | 3 |
| feedback | 1 |
| notices | 2 |
| audit_logs | 3 |
| **Total** | **44** |

The database schema supports six appointment statuses:

- BOOKED
- ARRIVED
- IN_CONSULTATION
- COMPLETED
- NO_SHOW
- CANCELLED

All seed records are fictional and intended for development and testing.

## 10. Database Testing and Validation

Database validation queries are maintained in:

`database/tests/database-validation.sql`

The following validations are included:

- Counting records in all 14 tables.
- Detecting duplicate appointment numbers.
- Detecting duplicate active appointments.
- Checking invalid session room references.
- Checking appointment cancellation timestamps.
- Validating session time ranges.
- Validating consultation time ranges.
- Validating feedback ratings.
- Checking invalid payment records.
- Checking invalid appointment numbers.

The expected result for the duplicate and invalid-record checks is zero rows.

## 11. Security Considerations

The database design supports the security requirements of MediChannel.

The application is responsible for:

- Encrypting sensitive personal and medical information using AES-256-GCM.
- Storing passwords using bcrypt password hashing.
- Using HMAC-SHA256 lookup hashes for protected email and NIC equality searches.
- Keeping cryptographic secrets in environment variables.
- Enforcing access restrictions so medical information is accessible only to the patient and treating doctor.

**Development note:** The current seed records contain placeholder encrypted values and demonstration lookup hashes. They are suitable for database structure testing, not production authentication or real encrypted-data testing. Proper application-generated cryptographic test data must be used when integrating the backend.

## 12. Database Implementation Files

| File | Description |
|---|---|
| database/schema.sql | Initial database schema |
| database/seed/seed.sql | Fictional development seed data |
| database/erd/medichannel-erd.md | Entity relationship diagram |
| database/tests/database-validation.sql | Database validation queries |

## 13. Conclusion

The MediChannel PostgreSQL database has been implemented with **14 relational tables**, primary and foreign keys, validation constraints, indexes and 44 fictional seed records.

Database validation queries have been prepared to check data consistency, appointment rules, payment information and relationships between tables.

The database is prepared for integration with the Spring Boot backend and Next.js frontend, subject to application-level security and integration testing.