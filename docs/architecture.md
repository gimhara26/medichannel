# Architecture

```mermaid
flowchart LR
  Browser[Browser / Next.js] -->|HTTPS + HTTP-only cookie| API[Spring Boot REST API]
  Browser <-->|WSS / STOMP| WS[Spring Boot WebSocket]
  API --> DB[(PostgreSQL)]
  WS --> DB
  API --> Cache[In-memory TTL cache]
```

The browser communicates with the Next.js frontend. The frontend calls the Spring Boot API for business operations. The backend owns validation, authorization, booking transactions and persistence. WebSocket events are authenticated and authorized server-side for every subscription and message.
