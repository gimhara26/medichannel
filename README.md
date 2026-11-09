# MediChannel – Hospital Channelling and Appointment System

Full-stack group project for IT404050 Full Stack Development.

## Technology
- Frontend: Next.js App Router, TypeScript, Tailwind CSS
- Backend: Java 21, Spring Boot, Spring Security, Spring Data JPA, STOMP WebSocket
- Database: PostgreSQL
- Deployment target: Vercel (frontend), Render (API/WebSocket), Neon (PostgreSQL)

## Repository layout
- `frontend/` – Next.js application
- `backend/` – Spring Boot REST API and WebSocket server
- `database/` – schema, seed data and ERD source
- `docs/` – architecture, API, security, testing and user documentation
- `infra/` – local development and deployment configuration

## Prerequisites
- Node.js 20+
- Java 21
- Maven 3.9+
- PostgreSQL 16+
- Git

## Quick start

### 1. Clone and configure
```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd medichannel
cp .env.example .env
```
Fill `.env` with local development secrets. Never commit `.env`.

### 2. Start PostgreSQL
```bash
docker compose -f infra/docker-compose.yml up -d postgres
```

### 3. Start the backend
```bash
cd backend
./mvnw spring-boot:run
```
The API is intended to run at `http://localhost:8080`.

### 4. Start the frontend
```bash
cd frontend
npm install
npm run dev
```
The frontend is intended to run at `http://localhost:3000`.

## Environment variables
See `.env.example`. Configure matching values in the frontend and backend deployment environments. Production secrets must be configured through the hosting provider, not committed to Git.

## Initial implementation order
1. Database schema, constraints, indexes and fictional seed data.
2. Authentication, account roles and server-side authorization.
3. Specialisations, doctors, rooms and sessions.
4. Transaction-safe appointment booking and cancellation rules.
5. Patient, doctor, manager and admin interfaces.
6. STOMP live queue, availability, notifications and private consultation chat.
7. Encryption evidence, tests, caching and deployment.

## Git workflow
- `main`: stable integration branch
- `develop`: team integration branch
- `feature/<short-name>`: individual features
- `fix/<short-name>`: bug fixes

Create a pull request to `develop`; require at least one teammate review. Merge tested work to `main` for release. Use meaningful commits and ensure every member contributes.

## Important security rules
- Public registration creates CUSTOMER accounts only.
- ADMIN creates DOCTOR and MANAGER accounts.
- Enforce authorization and ownership in the backend, including WebSocket subscriptions and messages.
- ADMIN and MANAGER must never access consultation notes, prescriptions, reasons for visit or chat messages.
- Hash passwords with BCrypt.
- Encrypt specified personal and medical fields using AES-256-GCM with a fresh random IV per value.
- Use HMAC-SHA256 lookup hashes for email and NIC.
- Do not log personal data, tokens, medical data or secrets.
- Use fictional patient data only.

## Status
This repository is an initial project scaffold. Complete the TODOs, verify all business rules and add tests before treating any feature as production-ready.
