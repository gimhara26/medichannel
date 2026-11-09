# Security and encryption checklist

- [ ] HTTPS and WSS in production
- [ ] BCrypt password hashes only
- [ ] AES-256-GCM with fresh random IV for every protected value
- [ ] HMAC-SHA256 hashes for email and NIC lookup/uniqueness
- [ ] Secrets loaded only from environment variables
- [ ] JWT expiry and HTTP-only Secure cookies
- [ ] Role and ownership checks on REST and WebSocket operations
- [ ] ADMIN/MANAGER cannot access consultation content
- [ ] No sensitive values in logs or audit records
- [ ] Capture ciphertext database evidence and readable application evidence
