# Security Model

## Product Principle

Heimdall protects during risky moments. It should not become a hidden surveillance system.

## Trust Boundaries

- Parent console: manages family settings and receives alerts.
- Child iPhone app: requests authorization, runs protection UI, and handles shared text checks.
- Backend API: stores family configuration and alert events.
- Apple Screen Time APIs: provide Family Controls, Device Activity, and Managed Settings capabilities after entitlement approval.

## Data Rules

1. Store risk reasons, not full conversations.
2. Store the minimum event data needed to explain a safety alert.
3. Avoid collecting raw messenger histories.
4. Make all protection behavior visible and explainable.
5. Use strong authentication before showing family data.

## First Production Requirements

- HTTPS only.
- Parent authentication.
- Per-family authorization.
- Device enrollment tokens.
- Push notification signing.
- Server-side audit log.
- Retention policy for alerts.
- Rate limits on analysis endpoints.

## High-Risk Events

- code or password request;
- bank or money transfer request;
- remote-access app installation;
- request to hide from parents;
- new contact moving from game to private messenger;
- request for address, location, documents, or private photos.
