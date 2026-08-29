# ProjectHub — Architecture & Decision Log

This document is a running, chronological record of **architectural decisions, tradeoffs, and rationale** made during the implementation of ProjectHub.

---

## 🏛 Phase 1 — Authentication & Security

### Decision: Multi-Session Refresh Tokens (Dedicated Table)
- **Choice:** Created a dedicated `RefreshToken` entity table with FK to `AppUser`, instead of a single `CurrentRefreshToken` column on `AppUser`.
- **Reasoning:** A single column breaks multi-device/multi-browser logins (a second login would silently revoke the first session). Multi-session support is essential for cross-platform (Web + Mobile) support.

### Decision: SHA256 Token Hashing
- **Choice:** Store SHA256 hashes of refresh tokens in the database rather than plaintext.
- **Reasoning:** A refresh token is a bearer credential. If the database is compromised, plaintext tokens allow immediate account hijacking. SHA256 is fast and sufficient because refresh tokens are high-entropy cryptographic strings (64 random bytes).

### Decision: Refresh Token Rotation with `IsUsed` Detection
- **Choice:** Mark tokens with `IsUsed = true` upon rotation instead of immediately deleting the row.
- **Reasoning:** Retaining consumed tokens enables **token reuse detection** (a critical indicator of token theft where both attacker and legitimate user present the same refresh token).

### Decision: Dedicated `ForbiddenException` (403)
- **Choice:** Created `ForbiddenException` mapped to HTTP 403 in `ExceptionHandlingMiddleware`, rather than overloading `UnauthorizedAccessException` (401).
- **Reasoning:** 401 indicates unauthenticated requests (missing/invalid JWT); 403 indicates authenticated users attempting operations outside their permission scope (e.g. non-owner deleting a workspace).

---

## 🏢 Phase 2 — Workspaces & Role Isolation

### Decision: No `OwnerId` Field on `WorkSpace`; Single Source of Truth
- **Choice:** Workspace ownership is determined exclusively by `WorkspaceMember.Role == "Owner"`.
- **Reasoning:** Storing `OwnerId` on `WorkSpace` alongside a `WorkspaceMember` row with `Role = "Owner"` creates dual sources of truth that can get out of sync.
- **Invariant:** Creating a workspace atomically creates the Owner's `WorkspaceMember` record within a single database transaction.

### Decision: Direct Member Invitation for MVP
- **Choice:** Direct addition of members by email (`POST /workspaces/{id}/members`) instead of a multi-state invite machine (`Pending -> Accepted -> Expired`).
- **Reasoning:** An invitation state machine requires email delivery infrastructure (SMTP / SendGrid) which is out of scope for early MVP testing.

---

## 📁 Phase 3 — Projects & Boundary Simplification

### Decision: Workspace as the Isolation Boundary (Removed `ProjectMember` Table)
- **Choice:** Removed the experimental `ProjectMember` join table and localized all permission checks to the parent `WorkSpace`.
- **Reasoning:** Having project-level membership creates unnecessary authorization overhead when all workspace members share access to workspace projects.
- **Rule:** All workspace members can view projects and create tasks. Only the Workspace Owner or Project Creator (`CreatedBy == userId`) can edit or delete a project.

---

## 📋 Phase 4 — Tasks & Kanban Management

### Decision: String Enums with FluentValidation
- **Choice:** Application enums (`TaskItemStatus`, `TaskItemPriority`, `ProjectStatus`) are stored as readable strings in PostgreSQL and validated on incoming DTOs using FluentValidation `IsEnumName`.
- **Reasoning:** Improves database inspectability and avoids brittle integer-to-enum mapping bugs during migrations.

### Decision: Dedicated PATCH Endpoints for Kanban & Assignment
- **Choice:** Provided `PATCH /tasks/{id}/status` and `PATCH /tasks/{id}/assignee` alongside full `PUT /tasks/{id}`.
- **Reasoning:**
  - `PATCH /tasks/{id}/status` optimizes Kanban drag-and-drop column moves with minimal network payloads.
  - `UpdateTaskRequestDto` (PUT) intentionally omits `Status` to prevent accidental status overwrites during general edits.

### Decision: Automated Task Unassignment on Member Removal
- **Choice:** When a member is removed from a workspace (`DELETE /workspaces/{id}/members/{userId}`), any tasks assigned to that user in that workspace have `AssigneeId` set to `null`.
- **Reasoning:** Prevents dangling assignee references to users who no longer have access to the workspace.

---

## 🔮 Future Architecture Checkpoints

1. **Clean Architecture Separation:** When feature complexity grows in Phase 5+ (comments, attachments, real-time), extract `ProjectHub.Domain` and `ProjectHub.Application` class libraries.
2. **Shared Authorization Policies:** Extract controller-level permission checks into ASP.NET Core `IAuthorizationHandler` policies if duplication increases.
3. **Session Cascade Revocation:** Implement automated session revocation if a compromised refresh token reuse is detected.

