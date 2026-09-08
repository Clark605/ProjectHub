# URL-Segment API Versioning

All HTTP endpoints are explicitly prefixed with `/api/v1/` (e.g., `/api/v1/auth/login`, `/api/v1/workspaces`, `/api/v1/tasks/{id}/status`) rather than relying on unversioned root paths or request headers. This provides unmistakable API contract boundaries, simplifies reverse-proxy and gateway routing, makes API evolution transparent to clients and API documentation consumers, and directly aligns with production standards expected in modern distributed architectures.
