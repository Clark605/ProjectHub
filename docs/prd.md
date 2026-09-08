# Product Requirements Document — ProjectHub (Solo-Build Edition)

**Product:** ProjectHub  
**Version:** 1.0 (MVP)  
**Platform:** Flutter Mobile/Web + ASP.NET Core 10 Web API  
**Database:** PostgreSQL  
**Document Status:** Approved & Baseline MVP Implemented  
**Primary Goal:** Build a responsive project management and team collaboration platform, scoped so one developer can ship a working, robustly architected MVP without stalling on premature complexity.

---

## 1. Product Overview

**ProjectHub** is a collaborative project and task management platform for organizing workspaces, tracking projects, and managing tasks visually on Kanban boards.

- Each user belongs to one or more **workspaces**.
- Each workspace contains **projects**.
- Each project contains **tasks** tracked via a **Kanban board**.

### MVP Core Capabilities
- Create, manage, and switch workspaces
- Direct-add and remove workspace members by email
- Create, manage, archive, and delete projects
- Create, assign, edit, and track tasks
- Move tasks across Kanban status columns (`Backlog`, `Todo`, `InProgress`, `Review`, `Done`)

---

## 2. Product Goals & Non-Goals

### Core Goals
- **G1 — Project Management:** Provide a clean, intuitive structure to organize projects and tasks.
- **G2 — Team Collaboration:** Allow workspace members to collaborate around shared projects.
- **G3 — Visibility & Focus:** Give users clear visibility into task priority, assignments, and due dates.
- **G4 — Solo-Buildable & Maintainable:** Every phase is independently shippable, testable, and maintainable without bloated dependencies.
- **G5 — Production-Quality Patterns:** Adopt clean architectural patterns with strongly-typed contracts, caching, and resilient networking.

### Non-Goals (Out of Scope for MVP)
- Financial management, billing, invoicing, payroll
- Video conferencing or rich in-app document editing
- Complex, custom per-field permission engines
- Premature real-time SignalR before Phase 5/6 gates

---

## 3. Simplified User Roles & Security Boundary

To keep QA lean and maintainable, ProjectHub enforces a streamlined **two-tier role model** at the workspace isolation boundary (see [ADR-0001](./adr/0001-implicit-workspace-membership-for-projects.md) and [ADR-0003](./adr/0003-workspace-owner-single-source-of-truth.md)).

| Permission | Workspace `Owner` | Project / Task Creator (`CreatedBy == userId`) | Task Assignee (`AssigneeId == userId`) | Workspace `Member` |
| :--- | :---: | :---: | :---: | :---: |
| **View Workspace & Members** | ✅ | ✅ | ✅ | ✅ |
| **Edit / Delete Workspace** | ✅ | ❌ | ❌ | ❌ |
| **Invite / Remove Members** | ✅ | ❌ | ❌ | ❌ |
| **Create Project** | ✅ | ✅ | ✅ | ✅ |
| **Edit / Delete Project** | ✅ | ✅ | ❌ | ❌ |
| **Create Task** | ✅ | ✅ | ✅ | ✅ |
| **Move Task Status (Kanban)**| ✅ | ✅ | ✅ | ❌ |
| **Assign / Reassign Task** | ✅ | ✅ | ✅ | ✅ |
| **Delete Task** | ✅ | ✅ | ❌ | ❌ |

---

## 4. Core Features Specification

### 4.1 Authentication & Profile
- **Registration & Login:** Identity-backed account creation with JWT access tokens and refresh tokens.
- **Refresh Token Rotation:** Multi-session refresh tokens with hash verification and token reuse detection (see [ADR-0005](./adr/0005-multi-session-sha256-refresh-token-rotation.md)).
- **Profile:** User profile retrieval and updates (`Name`, `Bio`, `Email`) with cache invalidation.
- **Password Reset:** Dev-mode reset token generation and verification endpoints.

### 4.2 Workspaces
- **Attributes:** `Id`, `Name`, `Description`, `CreatedAt`, `UpdatedAt`.
- **Operations:** Create workspace (creator automatically becomes `Owner`), update name/description, delete workspace (cascades cleanly). Ownership single source of truth is `WorkspaceMember.Role == "Owner"` (see [ADR-0003](./adr/0003-workspace-owner-single-source-of-truth.md)).
- **Membership:** Direct add by email, remove member (with automatic task unassignment for removed users, see [ADR-0006](./adr/0006-automatic-task-unassignment-on-member-removal.md)).

### 4.3 Projects
- **Attributes:** `Id`, `WorkspaceId`, `Name`, `Description`, `Status` (`Planning`, `Active`, `Completed`, `Archived`), `DueDate`, `CreatedBy`, `CreatedAt`, `UpdatedAt`.
- **Access Boundary:** Implicit workspace membership — all workspace members access all workspace projects (see [ADR-0001](./adr/0001-implicit-workspace-membership-for-projects.md)).
- **Operations:** Create project, update details, delete project, filter projects by status.
- **Archiving Invariant:** Setting status to `Archived` freezes the project and associated tasks as strictly read-only (see [ADR-0002](./adr/0002-strict-read-only-freeze-on-archived-projects.md)).

### 4.4 Tasks & Kanban Board
- **Attributes:** `Id`, `ProjectId`, `Title`, `Description`, `Status` (`Backlog`, `Todo`, `InProgress`, `Review`, `Done`), `Priority` (`Low`, `Medium`, `High`, `Urgent`), `AssigneeId`, `CreatedBy`, `DueDate`, `CreatedAt`, `UpdatedAt`.
- **Operations:** Create task, update details, delete task, filter by status / assignee / priority.
- **Dedicated Kanban PATCH Endpoints (see [ADR-0004](./adr/0004-dedicated-patch-endpoints-for-kanban-status-and-assignee.md)):**
  - `PATCH /tasks/{id}/status` for status changes (drag-and-drop / column moves).
  - `PATCH /tasks/{id}/assignee` for assigning tasks to workspace members.
- **Mobile Navigation & Interaction (see [ADR-0007](./adr/0007-responsive-kanban-navigation-and-modal-interactions.md)):**
  - Swipeable `PageView` + segmented column tabs on mobile viewports (< 768px).
  - Draggable modal bottom sheet on mobile; centered modal on desktop.

### 4.5 Personalization, Theming & App Settings (Phase 4.5)
- **Unified Profile & Settings Hub:** Combined account editing, appearance configuration, localization, FAQ, and version details in a single view (`/profile`, see [ADR-0014](./adr/0014-unified-profile-settings-and-dynamic-theming.md)).
- **Dynamic Color Palettes:** 6 curated color palettes (Deep Slate, Ocean Breeze, Sunset Ember, Forest Moss, Rose Gold, Midnight Purple) dynamically restyling surfaces, accents, typography, and `AmbientGlowBackground`.
- **Theme Mode & Localization:** Dark, Light, and System theme switching with English and Arabic locale support persisted across sessions.
- **Hero & Motion Polish:** Hero animation transitions on Kanban task cards and consistent skeleton loading states.

### 4.6 Security Hardening, External OAuth & Versioning (Phase 4.5)
- **URL-Segment API Versioning:** All endpoints systematically versioned under `/api/v1/` (see [ADR-0010](./adr/0010-url-segment-api-versioning.md)).
- **Native External OAuth:** Support for Google and GitHub authentication via native client SDKs and backend verification (`POST /api/v1/auth/external-login`, see [ADR-0012](./adr/0012-native-client-external-oauth-integration.md)).
- **Two-Tier Rate Limiting:** Global IP rate limits (100 req/min) combined with tight auth protections (see [ADR-0013](./adr/0013-two-tier-rate-limiting.md)).
- **Health Check Infrastructure:** Production diagnostic endpoint (`GET /api/v1/health`) reporting DB and Redis connectivity.

### 4.7 Activity Feed & Audit Logging (Phase 4.5)
- **Audit Trail & Activity Logging:** Single-table `ActivityEvent` audit log decoupled via `IActivityLogger` (see [ADR-0011](./adr/0011-activity-event-audit-trail-and-logger.md)).
- **Dual Feed Surfaces:** Workspace activity feed on the main Dashboard and scoped project activity log on project detail views.

---

## 5. Development Phases & Roadmap

```mermaid
gantt
    title ProjectHub Development Roadmap
    dateFormat  YYYY-MM-DD
    section MVP Core
    Phase 0 - Foundation (.NET 10 & Flutter)      :done, 2026-08-01, 2026-08-05
    Phase 1 - Auth & Token Rotation              :done, 2026-08-06, 2026-08-12
    Phase 2 - Workspaces & RBAC                  :done, 2026-08-13, 2026-08-18
    Phase 3 - Projects Management                :done, 2026-08-19, 2026-08-23
    Phase 4 - Tasks & Kanban Board               :done, 2026-08-24, 2026-09-07
    Phase 4.5 - Polish & Portfolio Enhancement   :active, 2026-09-08, 2026-09-20
    section Post-MVP
    Phase 5 - Collaboration (Comments & Mentions):2026-09-21, 2026-10-05
    Phase 6 - Real-Time (SignalR) & Notifications:2026-10-06, 2026-10-20
    Phase 7 - Search & Analytics                 :2026-10-21, 2026-11-04
    Phase 8 - Production Deployment & Monitoring :2026-11-05, 2026-11-20
```

---

## 6. Phase Gates for Post-MVP Features

To avoid scope creep, subsequent phases have strict stability criteria:

1. **Phase 4.5 (Polish & Portfolio Gate):** Dynamic color palette switcher, unified profile & settings, URL versioning, and activity logging must pass static analysis and unit testing before proceeding.
2. **Phase 5 (Collaboration):** Requires using the Kanban board and activity feed for day-to-day task tracking for at least two weeks with zero data loss or synchronization anomalies.
3. **Phase 6 (Real-Time SignalR):** SignalR will only be added after offline/silent refresh resilience and REST API correctness are established in production.
