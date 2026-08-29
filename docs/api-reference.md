# ProjectHub — REST API Reference

Comprehensive specification of all endpoints available in the **ProjectHub.Api** backend.

---

## 🌐 Base URL & Common Headers

- **Local Development:** `http://localhost:5259` or `https://localhost:7125`
- **Swagger Documentation:** `http://localhost:5259/swagger`

### Headers

| Header | Description | Required |
| :--- | :--- | :---: |
| `Content-Type` | Must be `application/json` | Yes (for POST / PUT / PATCH) |
| `Authorization` | `Bearer <JWT_ACCESS_TOKEN>` | Yes (for protected endpoints) |

---

## 🛡 Standardized Error Format

All error responses adhere to the `ApiErrorResponse` schema:

```json
{
  "statusCode": 400,
  "message": "Request is invalid.",
  "details": "The Title field is required."
}
```

| HTTP Status | Meaning | Typical Trigger |
| :--- | :--- | :--- |
| `400 Bad Request` | Validation failure or malformed payload | Invalid JSON or FluentValidation error |
| `401 Unauthorized` | Missing, expired, or invalid JWT | Invalid bearer token |
| `403 Forbidden` | Authenticated user lacks permission | Non-owner attempting owner actions |
| `404 Not Found` | Requested resource does not exist | Invalid ID for workspace, project, or task |
| `500 Server Error` | Unexpected internal server exception | Database connectivity issues |

---

## 🔑 Authentication Endpoints (`/auth`)

### 1. Register User
`POST /auth/register`

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
`POST /auth/login`

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

### 3. Refresh Token (Rotation)
`POST /auth/refresh`

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

### 4. Logout
`POST /auth/logout`

#### Request Body
```json
{
  "refreshToken": "8f3b2c14..."
}
```

#### Response (`200 OK`)

---

### 5. Forgot Password & Reset Password
- `POST /auth/forgot-password`: Generates reset token (dev mode).
- `POST /auth/reset-password`: Resets user password using the token.

---

## 👤 Users Endpoints (`/users`)

### 1. Get Profile
`GET /users/me` (Authenticated)

#### Response (`200 OK`)
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "bio": "Software Engineer & Designer"
}
```

### 2. Update Profile
`PUT /users/me` (Authenticated)

#### Request Body
```json
{
  "name": "Jane Doe",
  "bio": "Lead Software Architect"
}
```

---

## 🏢 Workspaces Endpoints (`/workspaces`)

### 1. List User Workspaces
`GET /workspaces` (Authenticated)

#### Response (`200 OK`)
```json
[
  {
    "id": 1,
    "name": "Engineering Team",
    "description": "Core software projects and infrastructure",
    "role": "Owner",
    "createdAt": "2026-08-29T10:00:00Z"
  }
]
```

### 2. Create Workspace
`POST /workspaces` (Authenticated)

#### Request Body
```json
{
  "name": "Design Systems",
  "description": "Figma tokens and UI components"
}
```

### 3. Get Workspace by ID
`GET /workspaces/{id}` (Authenticated)

### 4. Update Workspace
`PUT /workspaces/{id}` (Authenticated, Owner only)

### 5. Delete Workspace
`DELETE /workspaces/{id}` (Authenticated, Owner only)

### 6. Workspace Members
- `GET /workspaces/{id}/members` — List all members.
- `POST /workspaces/{id}/members` — Add member by email (`{"email": "colleague@example.com"}`).
- `DELETE /workspaces/{id}/members/{userId}` — Remove member from workspace.

### 7. Workspace Projects
- `GET /workspaces/{id}/projects?status=Active` — List projects in workspace.
- `POST /workspaces/{id}/projects` — Create project inside workspace.

---

## 📁 Projects Endpoints (`/projects`)

### 1. Get Project Details
`GET /projects/{id}` (Authenticated)

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
`PUT /projects/{id}` (Owner or Creator)

### 3. Delete Project
`DELETE /projects/{id}` (Owner or Creator)

### 4. Project Tasks
- `GET /projects/{id}/tasks?status=InProgress&priority=High` — List tasks with optional query filters.
- `POST /projects/{id}/tasks` — Create task inside project.

---

## 📋 Tasks Endpoints (`/tasks`)

### 1. Get Task
`GET /tasks/{id}` (Authenticated)

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
  "createdAt": "2026-08-29T11:00:00Z"
}
```

### 2. Update Task
`PUT /tasks/{id}` (Authenticated, Owner/Creator/Assignee)

#### Request Body
```json
{
  "title": "Implement Refresh Token Interceptor",
  "description": "Updated requirements with queue lock",
  "priority": "Urgent",
  "dueDate": "2026-09-04T00:00:00Z"
}
```

### 3. Move Task Status (Kanban Drag-Drop)
`PATCH /tasks/{id}/status` (Authenticated)

#### Request Body
```json
{
  "status": "Done"
}
```

### 4. Assign Task
`PATCH /tasks/{id}/assignee` (Authenticated)

#### Request Body
```json
{
  "assigneeId": "user-guid-456"
}
```

### 5. Delete Task
`DELETE /tasks/{id}` (Authenticated, Owner or Creator)

