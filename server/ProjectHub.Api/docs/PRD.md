# Product Requirements Document — Project Hub (Solo-Build Edition)
 
**Product:** Project Hub
**Version:** 1.0 (trimmed for solo development)
**Platform:** Flutter Mobile/Web + ASP.NET Core Web API
**Database:** SQL Server
**Document Status:** Draft
**Primary Goal:** Build a project management and team collaboration platform, scoped so one developer can ship a working, well-architected MVP without stalling on premature complexity.
 
**What changed from v1:** single role tier instead of two, no Viewer role in MVP, no configurable "Optional" permissions, ERD emerges from code instead of being designed upfront, SignalR is a hard phase gate instead of ambient architecture, ~40% fewer entities in MVP.
 
---
 
# 1. Product Overview
 
**Project Hub** is a collaborative project management platform for organizing projects, managing tasks, and tracking progress from a single app.
 
Each user belongs to one or more **workspaces**. Each workspace contains projects. Each project contains tasks.
 
MVP users can:
 
* Create and manage workspaces
* Invite team members
* Create and manage projects
* Create, assign, and track tasks
* Use a Kanban board
Everything else — comments, files, notifications, real-time, search, analytics — is deliberately deferred. See Section 20.
 
---
 
# 2. Product Goals
 
### G1 — Project Management
Provide a simple way to organize projects and tasks.
 
### G2 — Team Collaboration
Allow members to work together around shared projects.
 
### G3 — Visibility
Give users a clear view of what's assigned to them and what's due.
 
### G4 — Solo-Buildable Architecture
Every phase must be independently shippable and testable by one person without needing multiple simulated users or complex tooling.
 
### G5 — Production-Quality Patterns, Introduced Gradually
Use Clean Architecture, but don't front-load the full 4-layer ceremony before there's a reason for it. Let structure earn its complexity.
 
---
 
# 3. Non-Goals
 
Not attempting to compete with Jira/MS Project. Out of scope for v1 and v2:
 
* Financial management, payroll, ERP
* Video conferencing, full document editing
* AI features
* Complex billing/subscriptions
* Configurable/custom permission sets
---
 
# 4. Target Users
 
Same as original: individuals, small teams, project managers. No change — this was never the problem.
 
---
 
# 5. User Roles — Simplified
 
**Original v1 had two role tiers (System roles + Workspace roles) and four workspace roles including a Viewer with partial/optional permissions. This is cut for MVP.**
 
## 5.1 Why this was cut
 
A solo developer is also the sole QA tester. Every role combination you define is a test matrix entry *you* manually re-check by hand, repeatedly, alone. The original matrix had 4 roles × ~15 permissions, several marked "Optional" — meaning per-workspace configurable permissions, which is its own feature hiding inside a table cell.
 
## 5.2 MVP Roles
 
Just workspace roles. No separate Platform Admin tier — that's a V2 feature only relevant once you have real external users to moderate.
 
| Permission          | Owner | Member |
| -------------------- | :---: | :----: |
| View workspace        |   ✅   |   ✅   |
| Edit workspace        |   ✅   |   ❌   |
| Delete workspace      |   ✅   |   ❌   |
| Invite members        |   ✅   |   ❌   |
| Remove members        |   ✅   |   ❌   |
| Create projects       |   ✅   |   ✅   |
| Delete projects       |   ✅   | Created only |
| Create tasks          |   ✅   |   ✅   |
| Assign tasks          |   ✅   |   ✅   |
| Edit tasks            |   ✅   | Assigned/created |
| Delete tasks          |   ✅   | Created only |
 
No "Optional" cells. No Admin role, no Viewer role. There is always exactly one Owner (the workspace creator). Every other member is a Member. If you later find you genuinely need Admin or Viewer, add it as a real, deliberate feature — not a placeholder from day one.
 
---
 
# 6. Core Features (MVP Set)
 
## 6.1 Authentication
Register, login, logout, refresh token, reset password. Email verification can wait — it adds an email-sending dependency (SMTP/SendGrid config) for zero learning value early on. Add it in Phase 1 only if you want the practice; otherwise defer to V1.
 
Use JWT access token + refresh token, ASP.NET Core Identity.
 
## 6.2 User Profile
Name, email, profile picture (optional — file upload can wait, see 6.9), bio.
 
Dropped from v1: job title, time zone, notification preferences — these only matter once notifications exist (Phase 6+ territory), so they're dead fields until then.
 
## 6.3 Workspaces
Unchanged in shape from v1, minus the Logo field (another file-upload dependency pulled in early for no reason).
 
```text
Workspace
├── Id
├── Name
├── Description
├── OwnerId
├── CreatedAt
└── UpdatedAt
```
 
Create, edit, delete, list, switch workspace.
 
## 6.4 Workspace Invitations
Kept, but simplified: **direct add-by-email for MVP**, not a full invitation state machine (Pending/Accepted/Rejected/Expired/Cancelled).
 
Why: the state machine only pays off once you have email delivery + a way for the invited person to respond asynchronously. Until then, if you're testing solo, you're just going to seed a second test account and add it directly. Build the real flow in V1 once notifications exist to actually notify someone of a pending invite.
 
## 6.5 Projects
Unchanged from v1.
 
```text
Project
├── Id
├── WorkspaceId
├── Name
├── Description
├── Status
├── DueDate
├── CreatedBy
├── CreatedAt
└── UpdatedAt
```
 
Statuses: `Planning, Active, Completed, Archived`. Dropped `On Hold` and `Priority` field — collapses a rarely-distinguishing status and defers project-level priority until you have enough projects for it to matter.
 
Features: create, edit, archive, delete, view project dashboard (all workspace members have access).
 
## 6.6 Tasks
Unchanged in shape — this is the real product, don't trim it.
 
```text
Task
├── Id
├── ProjectId
├── Title
├── Description
├── Status
├── Priority
├── AssigneeId
├── CreatedBy
├── DueDate
├── CreatedAt
└── UpdatedAt
```
 
Dropped: `EstimatedHours` — nobody solo-testing a Kanban board fills this in accurately, and nothing in MVP consumes it. Add it when Analytics (Phase 7) actually uses it.
 
Status: `Backlog, Todo, In Progress, Review, Done`
Priority: `Low, Medium, High, Urgent`
 
## 6.7 Kanban Board
Unchanged. This is your core deliverable — move tasks between columns, status change per move.
 
**Solo-dev note:** implement drag-and-drop last, after status-change-via-button works end to end. Drag-and-drop is a Flutter UI investment; don't let it block backend correctness.
 
---
 
# 7. Deferred Features (Not in MVP)
 
Everything below is explicitly out until Section 20's MVP milestone is done and *stable* — meaning you've used it yourself for at least a few real tasks, not just smoke-tested it.
 
* Comments (7.1 in original)
* File attachments (needs object storage setup — a whole side-quest of its own)
* Notifications (needs a channel: in-app minimum, push later)
* Activity feed (cheap to add later, expensive to maintain correctly alongside everything else early)
* Search
* Dashboard analytics / project analytics
* SignalR / real-time anything
## 7.1 Why real-time is a hard gate, not "keep in mind"
 
The original PRD's system diagram drew SignalR into the architecture from Phase 0, even though it's scoped to Phase 6. That's a trap: once it's in the diagram, it's tempting to add "just a small SignalR hook" while building Phase 2 or 3. Don't. Real-time is the single highest-complexity addition in this whole PRD relative to its learning value at this stage. It gets its own phase, and it doesn't start until Phases 1–4 have been used by you, by hand, for at least a week without it feeling broken.
 
---
 
# 8. Backend Architecture — Introduced Gradually, Not All at Once
 
Original v1 mandated full Clean Architecture (API / Application / Domain / Infrastructure, 4 projects) from Phase 0. For solo learning, this is expensive: every feature now touches 4 projects, and when you're also still learning EF Core and ASP.NET Core basics, that's a lot of "which folder does this go in" friction per task.
 
**Recommended sequencing instead:**
 
1. **Phase 0–1:** Single ASP.NET Core project. Minimal APIs or thin controllers, services folder, EF Core DbContext. No separate class libraries yet.
2. **Phase 2–3:** Once you're comfortable and the single project is getting cluttered, split into `Domain` + `Api` (2 projects). This is the point where the split actually pays for itself.
3. **Phase 4+:** Split further into full Clean Architecture (`Domain` / `Application` / `Infrastructure` / `API`) *if* you're feeling the pain of not having it — mixed EF Core concerns leaking into business logic, hard-to-test services, etc. If you're not feeling that pain, don't force the split just because the diagram says so.
This isn't skipping Clean Architecture — it's earning it. You'll understand *why* each layer exists because you'll have felt the problem it solves, which is a better way to learn it than copying a folder structure on day one.
 
---
 
# 9. API Design — MVP Endpoints Only
 
```text
POST /auth/register
POST /auth/login
POST /auth/refresh
POST /auth/logout
 
GET    /workspaces
POST   /workspaces
GET    /workspaces/{id}
PUT    /workspaces/{id}
DELETE /workspaces/{id}
 
GET    /workspaces/{id}/members
POST   /workspaces/{id}/members            (direct add, not invitation flow — see 6.4)
DELETE /workspaces/{id}/members/{userId}
 
GET    /workspaces/{id}/projects
POST   /workspaces/{id}/projects
GET    /projects/{id}
PUT    /projects/{id}
DELETE /projects/{id}
 
GET    /projects/{id}/tasks
POST   /projects/{id}/tasks
GET    /tasks/{id}
PUT    /tasks/{id}
DELETE /tasks/{id}
PATCH  /tasks/{id}/status
PATCH  /tasks/{id}/assignee
```
 
Everything else (comments, notifications, search) is added when its phase starts, not designed now.
 
---
 
# 10. Data Model — Let It Emerge
 
**Original v1's closing instruction was to design a full ERD + entity definitions + relationship diagram + permission matrix as the very next artifact, before any code.** This is dropped for solo development.
 
Instead:
 
* Start with the 4 MVP entities (User comes from Identity, Workspace, Project, Task) plus the join tables (WorkspaceMember, ProjectMember).
* Let EF Core migrations *be* your living ERD — each migration is a dated snapshot of the real schema, which is more trustworthy than a diagram drawn in advance and never updated.
* Only formalize a diagram once you're past MVP and the shape has stabilized enough to be worth documenting for your portfolio writeup.
```text
User (from Identity)
 │
 ├──── WorkspaceMember ──── Workspace
 │                              │
 │                              └── Project
 │                                    │
 │                                    ├── Task
 │                                    └── ProjectMember
```
 
---
 
# 11. Security Requirements — Unchanged, Not Optional
 
This is one place the original PRD was right and shouldn't be trimmed. Every protected endpoint still needs:
 
```text
Is authenticated?
        ↓
Is user a workspace member?
        ↓
Is user the Owner (for Owner-only actions)?
        ↓
Allow operation
```
 
With only two roles instead of four, this is now a much smaller thing to actually implement and test — but don't skip it because it feels like less to protect. JWT + password hashing + refresh token rotation stay as originally specified.
 
---
 
# 12. Flutter Application Architecture — Unchanged
 
No trims here — your existing Flutter/BLoC/Dio/GoRouter stack was never the bottleneck.
 
```text
Flutter
├── Core (Network, Router, Storage, Theme, Error Handling)
├── Features (Auth, Dashboard, Workspaces, Projects, Tasks, Profile)
└── Shared (Widgets, Extensions, Utils)
```
 
---
 
# 13. Development Phases — Solo-Sequenced
 
## Phase 0 — Foundation
Git repo, single ASP.NET Core project (see Section 8), SQL Server, Flutter project, Swagger, basic logging.
 
## Phase 1 — Authentication
Register, login, logout, JWT, refresh tokens, profile (name/email/bio only). Password reset if time allows; email verification deferred.
 
**Milestone:** you can create an account and log in from the Flutter app.
 
## Phase 2 — Workspaces
Create/edit/delete workspace, direct-add members, two-role permission check (Owner/Member).
 
**Milestone:** you and a second seeded test account can both see the same workspace with correct permissions.
 
## Phase 3 — Projects
Create/edit/archive/delete projects, basic project dashboard (all workspace members have access).
 
**Milestone:** a workspace has multiple projects you can navigate between.
 
## Phase 4 — Tasks + Kanban
Create/assign/edit/delete tasks, status changes via button first, then drag-and-drop, priority, due dates.
 
**Milestone — MVP COMPLETE.** You can run a real small project (even this one) through the app for at least a week.
 
**Stop here. Use it. Don't proceed to Phase 5 until Phase 4 has been lived in, not just demoed.**
 
---
 
## Phase 5 — Collaboration
Comments, mentions, activity feed, file attachments (now object storage is worth setting up).
 
## Phase 6 — Real-Time & Notifications
SignalR, real-time task/comment updates, in-app notifications, push (FCM). This phase does not start until Phase 4 has been stable in daily use — see Section 7.1.
 
## Phase 7 — Search & Analytics
Global search, project analytics, task statistics, EstimatedHours field (now it has a consumer).
 
## Phase 8 — Production Readiness
Tests, monitoring, Docker, CI/CD, deployment, backups. Split Clean Architecture layers fully here if you haven't already (see Section 8).
 
---
 
# 14. MVP Scope — Final
 
```text
✅ Authentication (no email verification)
✅ User profiles (name, email, bio)
✅ Workspaces (Owner/Member only)
✅ Direct member add (no invitation state machine)
✅ Projects (no priority field, no On Hold status)
✅ Tasks (no EstimatedHours)
✅ Kanban board (button-based status change first, drag-and-drop after)
 
❌ Everything in Section 7 (Deferred Features)
❌ Viewer/Admin roles
❌ Configurable permissions
❌ Full Clean Architecture split (until it's earned — Section 8)
❌ Upfront ERD (Section 10)
```
 
---
 
# 15. Why This Version Is More Buildable Solo
 
* **Fewer roles = fewer manual test paths.** 2 roles × ~11 permissions instead of 4 roles × ~15 with configurable cells. You can actually keep the full permission matrix in your head.
* **Architecture complexity is earned, not front-loaded.** You won't be learning EF Core and a 4-project Clean Architecture split at the same time.
* **No dependency side-quests block the core loop.** File storage, email delivery, and push notification setup are all deferred past the point where the Kanban board — the actual product — works end to end.
* **The MVP milestone forces real usage before scope grows.** "Live in Phase 4 for a week" is a concrete gate against the single biggest solo-project risk: endlessly adding phases without ever finishing one.
* **The ERD emerges from migrations.** No time spent designing a schema for entities (Notification, Activity, Attachment) that don't exist yet in your codebase.