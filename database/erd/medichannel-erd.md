
erDiagram

    USERS {
        bigint id PK
        text email_ciphertext
        char email_lookup_hash UK
        varchar password_hash
        varchar role
        boolean active
    }

    PATIENTS {
        bigint id PK
        bigint user_id FK
        text full_name_ciphertext
        text nic_ciphertext
        char nic_lookup_hash UK
        text phone_ciphertext
    }

    SPECIALISATIONS {
        bigint id PK
        varchar name UK
        text description
        boolean active
    }

    DOCTORS {
        bigint id PK
        bigint user_id FK
        bigint specialisation_id FK
        text full_name_ciphertext
        varchar slmc_registration_number UK
        numeric default_fee
        boolean active
    }

    ROOMS {
        bigint id PK
        varchar room_name UK
        text location_description
        boolean active
    }

    SESSIONS {
        bigint id PK
        bigint doctor_id FK
        bigint room_id FK
        date session_date
        time start_time
        time end_time
        varchar session_type
        integer max_patients
        numeric fee
        varchar status
    }

    APPOINTMENTS {
        bigint id PK
        bigint session_id FK
        bigint patient_id FK
        integer appointment_number
        varchar appointment_type
        varchar booking_reference UK
        varchar status
        varchar payment_status
    }

    CONSULTATIONS {
        bigint id PK
        bigint appointment_id FK
        text diagnosis_ciphertext
        text advice_ciphertext
        text prescription_ciphertext
        timestamptz started_at
        timestamptz ended_at
    }

    CHAT_MESSAGES {
        bigint id PK
        bigint consultation_id FK
        bigint sender_user_id FK
        text message_ciphertext
        timestamptz created_at
    }

    NOTIFICATIONS {
        bigint id PK
        bigint user_id FK
        varchar notification_type
        varchar title
        text body
        timestamptz read_at
    }

    FEEDBACK {
        bigint id PK
        bigint appointment_id FK
        bigint patient_id FK
        integer rating
        text comment
        boolean visible
    }

    NOTICES {
        bigint id PK
        varchar title
        text body
        boolean published
        bigint created_by FK
    }

    AUDIT_LOGS {
        bigint id PK
        bigint actor_user_id FK
        varchar action
        varchar target_type
        varchar target_id
        inet ip_address
    }

    USERS ||--o| PATIENTS : "has profile"
    USERS ||--o| DOCTORS : "has profile"

    SPECIALISATIONS ||--o{ DOCTORS : "categorises"

    DOCTORS ||--o{ SESSIONS : "conducts"
    ROOMS o|--o{ SESSIONS : "hosts"

    SESSIONS ||--o{ APPOINTMENTS : "contains"
    PATIENTS ||--o{ APPOINTMENTS : "books"

    APPOINTMENTS ||--o| CONSULTATIONS : "has"

    CONSULTATIONS ||--o{ CHAT_MESSAGES : "contains"
    USERS ||--o{ CHAT_MESSAGES : "sends"

    USERS ||--o{ NOTIFICATIONS : "receives"

    APPOINTMENTS ||--o| FEEDBACK : "receives"
    PATIENTS ||--o{ FEEDBACK : "submits"

    USERS ||--o{ NOTICES : "creates"
    USERS o|--o{ AUDIT_LOGS : "performs"
