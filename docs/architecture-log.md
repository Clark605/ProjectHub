# ProjectHub — Architecture & Decision Index

This document is a running, chronological index of **architectural decisions, tradeoffs, and rationale** for ProjectHub. Each major decision is codified in a dedicated [Architecture Decision Record (ADR)](./adr/), which acts as the single authoritative source of truth.

---

## 🏛 Phase 1 — Authentication & Security

- **[ADR-0005: Multi-Session SHA256 Refresh Token Rotation](./adr/0005-multi-session-sha256-refresh-token-rotation.md)**  
  Dedicated `RefreshToken` entity with SHA256 token hashing, rotation, and `IsUsed` tracking for token reuse detection across mobile and web sessions.
- **Dedicated `ForbiddenException` (HTTP 403)**  
  Mapped to HTTP 403 in `ExceptionHandlingMiddleware` to distinguish authenticated permission denial (403) from unauthenticated requests (401).

---

## 🏢 Phase 2 — Workspaces & Role Isolation

- **[ADR-0003: Workspace Owner Single Source of Truth](./adr/0003-workspace-owner-single-source-of-truth.md)**  
  Workspace ownership is determined exclusively by `WorkspaceMember.Role == "Owner"`, eliminating dual sources of truth and synchronizing creation atomically.
- **Direct Member Invitation for MVP**  
  Direct addition by email (`POST /workspaces/{id}/members`) for MVP to defer email server (SMTP/SendGrid) infrastructure to post-MVP.

---

## 📁 Phase 3 — Projects & Boundary Simplification

- **[ADR-0001: Implicit Workspace Membership for Projects](./adr/0001-implicit-workspace-membership-for-projects.md)**  
  Eliminated the `ProjectMember` join table in favor of implicit workspace-level access, allowing all workspace members to access projects while restricting editing/deletion to Owners and Creators.
- **[ADR-0002: Strict Read-Only Freeze on Archived Projects](./adr/0002-strict-read-only-freeze-on-archived-projects.md)**  
  When a project is set to `Archived`, all task mutations, creation, deletions, and Kanban status moves are frozen as read-only.

---

## 📋 Phase 4 — Tasks & Kanban Management

- **[ADR-0004: Dedicated PATCH Endpoints for Kanban Status and Assignee](./adr/0004-dedicated-patch-endpoints-for-kanban-status-and-assignee.md)**  
  Provides minimal `PATCH /tasks/{id}/status` and `PATCH /tasks/{id}/assignee` endpoints to optimize drag-and-drop column moves and 1-tap reassignments. Full `PUT /tasks/{id}` excludes `Status` to prevent accidental overwrites.
- **[ADR-0006: Automatic Task Unassignment on Member Removal](./adr/0006-automatic-task-unassignment-on-member-removal.md)**  
  Removing a member from a workspace automatically sets `AssigneeId = null` on all tasks assigned to that user in that workspace.
- **[ADR-0007: Responsive Kanban Navigation and Modal Interactions](./adr/0007-responsive-kanban-navigation-and-modal-interactions.md)**  
  Mobile viewports (< 768px) use a swipeable `PageView` with segmented column tabs, while desktop/tablet uses multi-column views and centered modal dialogs.
- **String Enums with FluentValidation**  
  Domain enums (`TaskItemStatus`, `TaskItemPriority`, `ProjectStatus`) are persisted as readable strings in PostgreSQL and validated via FluentValidation.

---

## 🔮 Future Architectural Checkpoints

1. **Clean Architecture Extraction:** When post-MVP complexity increases (comments, attachments, real-time), extract separate `ProjectHub.Domain` and `ProjectHub.Application` assemblies.
2. **Shared Authorization Policies:** Extract controller-level permission checks into ASP.NET Core `IAuthorizationHandler` policies if policy duplication increases.
3. **Session Cascade Revocation:** Implement automated multi-session revocation when token theft is detected via reused refresh tokens.
