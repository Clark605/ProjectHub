# Two-Tier Rate Limiting for Abuse and Brute-Force Protection

To safeguard the API against denial-of-service, automated credential stuffing, and brute-force password guessing, the backend implements ASP.NET Core rate limiting using a two-tier policy strategy:
1. **Global Baseline Limit:** A sliding/fixed window limit (100 requests/minute per client IP) across all standard endpoints.
2. **Sensitive Auth Policy:** Stricter partitioned rate limits on authentication and recovery routes (`POST /api/v1/auth/login` at 5 req/min, `POST /api/v1/auth/register` at 3 req/min, and `POST /api/v1/auth/forgot-password` at 2 req/min).

This safeguards critical identity resources and external dependencies without disrupting legitimate user interactivity or background Kanban synchronization.
