# ProjectHub — REST API Reference

Comprehensive specification of all endpoints available in the **ProjectHub.Api** backend. All endpoints are systematically versioned under `/api/v1/` (see [ADR-0010](./adr/0010-url-segment-api-versioning.md)).

---

## 🌐 Base URL & Common Headers

- **Local Development:** `http://localhost:5259/api/v1` or `https://localhost:7125/api/v1`
- **Swagger Documentation:** `http://localhost:5259/swagger`

### Headers

| Header | Description | Required |
| :--- | :--- | :---: |
| `Content-Type` | Must be `application/json` | Yes (for POST / PUT / PATCH) |
| `Authorization` | `Bearer <JWT_ACCESS_TOKEN>` | Yes (for protected endpoints) |

### Rate Limiting Policy Headers (see [ADR-0013](./adr/0013-two-tier-rate-limiting.md))

When request thresholds are approached or exceeded, responses include standard rate limit headers:
- `429 Too Many Requests` when limit is exceeded.
- `Retry-After`: Seconds to wait before retrying.
- Sensitive auth endpoints (`/auth/login`, `/auth/register`, `/auth/forgot-password`) enforce strict partitioned limits (2-5 req/min). Global requests capped at 100 req/min per client IP.

---

## 🩺 System & Diagnostics (`/health`)

### 1. System Health Check (see [ADR-0018](./adr/0018-enum-schema-migration-and-resilient-caching.md))
`GET /api/v1/health`

#### Response (`200 OK` — Healthy)
```json
{
  "status": "Healthy",
  "components": {
    "database": "Connected",
    "redis": "Connected"
  },
  "uptime": "0.02:14:35",
  "timestamp": "2026-09-22T12:00:00Z"
}
```

#### Response (`200 OK` — Degraded / Redis Offline)
When Redis is down but PostgreSQL is connected, the API transparently falls back to L1 in-memory caching and continues serving requests:
```json
{
  "status": "Degraded",
  "components": {
    "database": "Connected",
    "redis": "Degraded (L1 Fallback)"
  },
  "uptime": "0.02:14:35",
  "timestamp": "2026-09-22T12:00:00Z"
}
```

#### Response (`503 Service Unavailable` — Unhealthy)
If the PostgreSQL database connection fails:
```json
{
  "status": "Unhealthy",
  "components": {
    "database": "Disconnected",
    "redis": "Connected"
  },
  "uptime": "0.02:14:35",
  "timestamp": "2026-09-22T12:00:00Z"
}
```

---

## 🛡 Standardized Error Format

All error responses adhere to the `ApiErrorResponse` schema:

```json
{
  "statusCode": 400,
  "message": "Request is invalid.",
  "details": "The Title field is required.",
  "traceId": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
}
```

| HTTP Status | Meaning | Typical Trigger |
| :--- | :--- | :--- |
| `400 Bad Request` | Validation failure or malformed payload | Invalid JSON or FluentValidation error |
| `401 Unauthorized` | Missing, expired, or invalid JWT | Invalid bearer token |
| `403 Forbidden` | Authenticated user lacks permission | Non-owner attempting owner actions |
| `404 Not Found` | Requested resource does not exist | Invalid ID for workspace, project, or task |
| `429 Too Many Requests` | Rate limit threshold exceeded | Exceeded 100 req/min or sensitive auth quota |
| `500 Server Error` | Unexpected internal server exception | Database connectivity issues |

---

## 🔑 Authentication Endpoints (`/api/v1/auth`)

### 1. Register User
`POST /api/v1/auth/register`

#### Request Body
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "Password123!"
}
```

#### Response (`200 OK`)
```json
{
  "token": "eyJhbGciOiJIUzI1Ni...",
  "refreshToken": "4a7c8b91..."
}
```

---

### 2. Login
`POST /api/v1/auth/login`

#### Request Body
```json
{
  "email": "jane@example.com",
  "password": "Password123!"
}
```

#### Response (`200 OK`)
```json
{
  "token": "eyJhbGciOiJIUzI1Ni...",
  "refreshToken": "4a7c8b91..."
}
```

---

### 3. External OAuth Login (Google & GitHub) (see [ADR-0012](./adr/0012-native-client-external-oauth-integration.md))
`POST /api/v1/auth/external-login`

#### Request Body (Google)
```json
{
  "provider": "Google",
  "idToken": "eyJhbGciOiJSUzI1NiIs..."
}
```

#### Request Body (GitHub)
```json
{
  "provider": "GitHub",
  "accessToken": "gho_EXAMPLE_MOCK_GITHUB_TOKEN_123456789"
}
```

#### Response (`200 OK`)
```json
{
  "token": "eyJhbGciOiJIUzI1Ni...",
  "refreshToken": "6b8d9c02..."
}
```

---

### 4. Refresh Token (Rotation)
`POST /api/v1/auth/refresh`

#### Request Body
```json
{
  "refreshToken": "4a7c8b91..."
}
```

#### Response (`200 OK`)
```json
{
  "token": "eyJhbGciOiJIUzI1Ni...",
  "refreshToken": "8f3b2c14..."
}
```

---

### 5. Logout
`POST /api/v1/auth/logout`

#### Request Body
```json
{
  "refreshToken": "8f3b2c14..."
}
```

#### Response (`200 OK`)

---

### 6. Forgot Password & Reset Password
- `POST /api/v1/auth/forgot-password`: Generates reset token (dev mode / email).
- `POST /api/v1/auth/reset-password`: Resets user password using the token.

---

## 👤 Users Endpoints (`/api/v1/users`)

### 1. Get Profile
`GET /api/v1/users/me` (Authenticated)

#### Response (`200 OK`)
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "bio": "Software Engineer & Designer"
}
```

### 2. Update Profile
`PUT /api/v1/users/me` (Authenticated)

#### Request Body
```json
{
  "name": "Jane Doe",
  "bio": "Lead Software Architect"
}
```

---

## 🏢 Workspaces Endpoints (`/api/v1/workspaces`)

### 1. List User Workspaces
`GET /api/v1/workspaces` (Authenticated)

#### Response (`200 OK`)
```json
[
  {
    "id": 1,
    "name": "Engineering Team",
    "description": "Core software projects and infrastructure",
    "accentColor": "teal",
    "role": "Owner",
    "createdAt": "2026-08-29T10:00:00Z"
  }
]
```

### 2. Create Workspace
`POST /api/v1/workspaces` (Authenticated)
- Server automatically assigns an accent color from the curated 10-color palette.

#### Request Body
```json
{
  "name": "Design Systems",
  "description": "Figma tokens and UI components"
}
```

### 3. Get Workspace by ID
`GET /api/v1/workspaces/{id}` (Authenticated)

### 4. Update Workspace
`PUT /api/v1/workspaces/{id}` (Authenticated, Owner only)

#### Request Body
```json
{
  "name": "Engineering Team",
  "description": "Core software projects and infrastructure",
  "accentColor": "violet"
}
```

### 5. Delete Workspace
`DELETE /api/v1/workspaces/{id}` (Authenticated, Owner only)

### 6. Workspace Members
- `GET /api/v1/workspaces/{id}/members` — List all members and their roles.
- `POST /api/v1/workspaces/{id}/members` — Add member by email (`{"email": "colleague@example.com"}`).
- `PUT /api/v1/workspaces/{id}/members/{userId}/role` — Update member role (`{"role": "Owner" | "Member"}`). Owner only. Synchronously busts cached role keys (see [ADR-0018](./adr/0018-enum-schema-migration-and-resilient-caching.md)).
- `DELETE /api/v1/workspaces/{id}/members/{userId}` — Remove member from workspace (triggers auto task unassignment).

### 7. Workspace Projects
- `GET /api/v1/workspaces/{id}/projects?status=Active` — List projects in workspace.
- `POST /api/v1/workspaces/{id}/projects` — Create project inside workspace.

### 8. Workspace My Tasks (Personal Focus View) (see [ADR-0008](./adr/0008-workspace-scoped-my-tasks-aggregation.md))
`GET /api/v1/workspaces/{id}/my-tasks` (Authenticated)
- Retrieves all tasks assigned to the authenticated user within the specified workspace.

### 9. Workspace Activity Feed (see [ADR-0011](./adr/0011-activity-event-audit-trail-and-logger.md))
`GET /api/v1/workspaces/{id}/activity?limit=20` (Authenticated)
- Retrieves the latest workspace activity events for the Dashboard feed.

---

## 🏷 Dual-Scope Tags Endpoints (see [ADR-0017](./adr/0017-signalr-realtime-collaboration-and-dual-scope-tags.md))

Tags are partitioned into reusable workspace-level tags (`ProjectId == null`) and project-scoped tags (`ProjectId != null`). Tag colors are deterministically hashed against a curated 12-color palette.

### 1. Create Workspace Tag
`POST /api/v1/workspaces/{workspaceId}/tags` (Authenticated, Owner only)

#### Request Body
```json
{
  "name": "Backend"
}
```

### 2. List Workspace Tags
`GET /api/v1/workspaces/{workspaceId}/tags` (Authenticated)

### 3. Create Project Tag
`POST /api/v1/projects/{projectId}/tags` (Authenticated, Owner or Creator)

#### Request Body
```json
{
  "name": "Sprint-1"
}
```

### 4. List Available Tags for Project
`GET /api/v1/projects/{projectId}/available-tags` (Authenticated)
- Returns combined list of workspace-level tags and project-scoped tags available for assignment.

### 5. Attach Tag to Task
`POST /api/v1/tasks/{taskId}/tags` (Authenticated)
- Enforces a maximum of 5 tags per task.

#### Request Body
```json
{
  "tagId": 3
}
```

### 6. Detach Tag from Task
`DELETE /api/v1/tasks/{taskId}/tags/{tagId}` (Authenticated)

### 7. Delete Tag
`DELETE /api/v1/tags/{id}` (Authenticated, Owner or Creator)
- Cascades cleanly through `TaskTag` join records without deleting tasks.

---

## 💬 Task Comments Endpoints (see [ADR-0017](./adr/0017-signalr-realtime-collaboration-and-dual-scope-tags.md))

Task discussions are modeled as single-level flat chronological comments. Adding or removing comments broadcasts real-time SignalR notifications and updates the task's `commentCount`.

### 1. List Task Comments
`GET /api/v1/tasks/{taskId}/comments` (Authenticated)

#### Response (`200 OK`)
```json
[
  {
    "id": 1,
    "taskId": 42,
    "userId": "user-guid-456",
    "userName": "Jane Doe",
    "content": "Added the Dio interceptor queue lock.",
    "createdAt": "2026-09-22T10:15:00Z",
    "updatedAt": null
  }
]
```

### 2. Create Comment
`POST /api/v1/tasks/{taskId}/comments` (Authenticated)

#### Request Body
```json
{
  "content": "Verified on Android emulator."
}
```

### 3. Update Comment
`PUT /api/v1/comments/{id}` (Authenticated, Author only)

#### Request Body
```json
{
  "content": "Verified on Android emulator and iOS simulator."
}
```

### 4. Delete Comment
`DELETE /api/v1/comments/{id}` (Authenticated, Author or Workspace Owner)

---

## 📁 Projects Endpoints (`/api/v1/projects`)

### 1. Get Project Details
`GET /api/v1/projects/{id}` (Authenticated)

#### Response (`200 OK`)
```json
{
  "id": 10,
  "workspaceId": 1,
  "name": "Mobile Client v1",
  "description": "Building the Flutter application",
  "status": "Active",
  "createdBy": "user-guid-123",
  "dueDate": "2026-09-30T00:00:00Z",
  "createdAt": "2026-08-29T10:00:00Z"
}
```

### 2. Update Project
`PUT /api/v1/projects/{id}` (Owner or Creator)

### 3. Delete Project
`DELETE /api/v1/projects/{id}` (Owner or Creator)

### 4. Project Tasks
- `GET /api/v1/projects/{id}/tasks?status=InProgress&priority=High` — List tasks with optional query filters.
- `POST /api/v1/projects/{id}/tasks` — Create task inside project. Supports optional `tagIds: [1, 2]` with pre-save ownership validation (see [ADR-0018](./adr/0018-enum-schema-migration-and-resilient-caching.md)).

### 5. Project Activity History (see [ADR-0011](./adr/0011-activity-event-audit-trail-and-logger.md))
`GET /api/v1/projects/{id}/activity?limit=50` (Authenticated)
- Retrieves granular task transitions and lifecycle events scoped strictly to this project.

---

## 📋 Tasks Endpoints (`/api/v1/tasks`)

### 1. Get Task
`GET /api/v1/tasks/{id}` (Authenticated)

#### Response (`200 OK`)
```json
{
  "id": 42,
  "projectId": 10,
  "title": "Implement Refresh Token Interceptor",
  "description": "Add Dio interceptor for 401 retry queue",
  "status": "InProgress",
  "priority": "High",
  "assigneeId": "user-guid-456",
  "createdBy": "user-guid-123",
  "dueDate": "2026-09-05T00:00:00Z",
  "commentCount": 3,
  "tags": [
    {
      "id": 1,
      "name": "Backend",
      "colorHex": "#3B82F6"
    }
  ],
  "createdAt": "2026-08-29T11:00:00Z"
}
```

### 2. Update Task
`PUT /api/v1/tasks/{id}` (Authenticated, Owner/Creator/Assignee)

#### Request Body
```json
{
  "title": "Implement Refresh Token Interceptor",
  "description": "Updated requirements with queue lock",
  "priority": "Urgent",
  "dueDate": "2026-09-04T00:00:00Z"
}
```

### 3. Move Task Status (Kanban Drag-Drop) (see [ADR-0004](./adr/0004-dedicated-patch-endpoints-for-kanban-status-and-assignee.md) and [ADR-0018](./adr/0018-enum-schema-migration-and-resilient-caching.md))
`PATCH /api/v1/tasks/{id}/status` (Authenticated)

#### Request Body
```json
{
  "status": "Done"
}
```

### 4. Assign Task (see [ADR-0004](./adr/0004-dedicated-patch-endpoints-for-kanban-status-and-assignee.md))
`PATCH /api/v1/tasks/{id}/assignee` (Authenticated)

#### Request Body
```json
{
  "assigneeId": "user-guid-456"
}
```

### 5. Delete Task
`DELETE /api/v1/tasks/{id}` (Authenticated, Owner or Creator)

---

## ⚡ Real-Time SignalR Hub Specification (see [ADR-0017](./adr/0017-signalr-realtime-collaboration-and-dual-scope-tags.md))

ProjectHub exposes an authenticated SignalR hub for bidirectional push synchronization and online presence.

- **Hub Endpoint:** `ws://localhost:5259/api/v1/hubs/workspace` (or `wss://`)
- **Authentication:** Bearer token transmitted via query string parameter `?access_token=<JWT>`.

### Client-to-Server Invocations

| Method | Parameters | Description |
| :--- | :--- | :--- |
| `JoinWorkspace` | `int workspaceId` | Adds connection to workspace group (`workspace-{id}`) and registers user in Redis online presence set. Broadcasts updated `PresenceChanged` event. |
| `LeaveWorkspace` | `int workspaceId` | Removes connection from workspace group, cleans up Redis presence set, and broadcasts updated `PresenceChanged` event. |

### Server-to-Client Broadcast Events

| Event Name | Target Group | Payload Schema | Trigger Condition |
| :--- | :--- | :--- | :--- |
| `PresenceChanged` | `workspace-{id}` | `{ workspaceId: int, onlineUserIds: string[] }` | Member joins, leaves, or abruptly disconnects (30s ping timeout) |
| `TaskCreated` | `workspace-{id}` | `TaskResponseDto` | New task created in project |
| `TaskStatusChanged`| `workspace-{id}` | `{ taskId: int, projectId: int, newStatus: string }` | Kanban card moved across columns |
| `TaskAssigned` | `workspace-{id}` | `{ taskId: int, assigneeId: string? }` | Task assignee updated or unassigned |
| `TaskDeleted` | `workspace-{id}` | `{ taskId: int, projectId: int }` | Task deleted |
| `CommentAdded` | `workspace-{id}` | `CommentResponseDto` | New comment posted to task |
| `CommentDeleted` | `workspace-{id}` | `{ taskId: int, commentId: int }` | Comment deleted |

