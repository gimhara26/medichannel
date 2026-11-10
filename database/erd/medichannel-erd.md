
erDiagram

    USERS {
        bigint id PK
        varchar full_name
        text email_encrypted
        char email_lookup_hash UK
        text password_hash
        varchar role
        boolean is_active
        timestamptz created_at
        timestamptz updated_at
    }

    PATIENTS {
        bigint id PK
        bigint user_id FK, UK
        text nic_encrypted
        char nic_lookup_hash UK
        date date_of_birth
        varchar gender
        text phone_encrypted
        text address_encrypted
        timestamptz created_at
    }

    SPECIALISATIONS {
        bigint id PK
        varchar name UK
        text description
        boolean is_active
    }

    DOCTORS {
        bigint id PK
        bigint user_id FK, UK
        bigint specialisation_id FK
        varchar qualification
        integer experience_years
        numeric consultation_fee
        boolean is_active
    }

    ROOMS {
        bigint id PK
        varchar room_name UK
        varchar location
        boolean is_active
    }

    SESSIONS {
        bigint id PK
        bigint doctor_id FK
        bigint room_id FK
        date session_date
        time start_time
        time end_time
        integer max_patients
        numeric consultation_fee
        varchar status
        timestamptz created_at
    }

    APPOINTMENTS {
        bigint id PK
        bigint session_id FK
        bigint patient_id FK
        integer appointment_number
        varchar appointment_status
        varchar payment_status
        varchar payment_method
        timestamptz booked_at
        timestamptz arrived_at
        timestamptz cancelled_at
    }

    PAYMENTS {
        bigint id PK
        bigint appointment_id FK, UK
        numeric amount
        varchar payment_method
        varchar payment_status
        timestamptz paid_at
        bigint recorded_by FK
        timestamptz created_at
    }

    CONSULTATIONS {
        bigint id PK
        bigint appointment_id FK, UK
        text consultation_notes_encrypted
        text prescription_encrypted
        timestamptz started_at
        timestamptz completed_at
    }

    CHAT_MESSAGES {
        bigint id PK
        bigint consultation_id FK
        bigint sender_user_id FK
        text message_encrypted
        timestamptz sent_at
    }

    NOTIFICATIONS {
        bigint id PK
        bigint user_id FK
        varchar title
        text message
        boolean is_read
        timestamptz created_at
    }

    FEEDBACK {
        bigint id PK
        bigint appointment_id FK, UK
        bigint patient_id FK
        integer rating
        text comment
        timestamptz created_at
    }

    NOTICES {
        bigint id PK
        varchar title
        text content
        bigint created_by FK
        timestamptz published_at
        timestamptz expires_at
        boolean is_active
    }

    AUDIT_LOGS {
        bigint id PK
        bigint actor_user_id FK
        varchar action
        varchar entity_type
        bigint entity_id
        timestamptz created_at
    }

    USERS ||--o| PATIENTS : "has profile"
    USERS ||--o| DOCTORS : "has profile"
    SPECIALISATIONS ||--o{ DOCTORS : "categorises"
    DOCTORS ||--o{ SESSIONS : "conducts"
    ROOMS ||--o{ SESSIONS : "hosts"
    SESSIONS ||--o{ APPOINTMENTS : "contains"
    PATIENTS ||--o{ APPOINTMENTS : "books"
    APPOINTMENTS ||--o| PAYMENTS : "has payment"
    USERS o|--o{ PAYMENTS : "records"
    APPOINTMENTS ||--o| CONSULTATIONS : "has"
    CONSULTATIONS ||--o{ CHAT_MESSAGES : "contains"
    USERS ||--o{ CHAT_MESSAGES : "sends"
    USERS ||--o{ NOTIFICATIONS : "receives"
    APPOINTMENTS ||--o| FEEDBACK : "receives"
    PATIENTS ||--o{ FEEDBACK : "submits"
    USERS ||--o{ NOTICES : "creates"
    USERS o|--o{ AUDIT_LOGS : "performs"
