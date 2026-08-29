# Project Hub — Architecture & Judgment Log

This is **not** a spec. `projectHub.md` stays the stable reference for *what* to build.
This file is a running, chronological record of *how* and *why* — real decisions made
while building, the reasoning behind them, and things deliberately deferred.

Add an entry whenever you:
- Make a real architecture/design tradeoff (not just "wrote a getter")
- Notice friction that *might* be a future refactor trigger, even if you don't act on it yet
- Deliberately keep something imperfect and want to remember why

---

## Phase 1 — Auth

### Decision: Multi-session refresh tokens (separate `RefreshToken` table, not a field on `AppUser`)
A single `CurrentRefreshToken` field on `AppUser` would break multi-device login (second
login invalidates the first). Chose a separate table, one row per session, FK to `AppUser`.
**Tradeoff accepted:** more complex than a single field, but multi-session support was a
deliberate requirement, not a default.

### Decision: Hash refresh tokens (SHA256) before storing
A refresh token *is* the credential — unlike a password, whoever holds the raw string can
use it directly, no separate secret needed. Hashing means DB compromise alone doesn't leak
usable tokens. SHA256 (not BCrypt) is fine here because the token is 64 random bytes —
already high-entropy, nothing to brute-force, so BCrypt's deliberate slowness buys nothing.

### Decision: Refresh token rotation with `IsUsed` tracking (not delete-on-use)
Marking tokens `IsUsed = true` instead of deleting lets you *detect* reuse of an
already-consumed token — a signal of theft (attacker and legit user both using the same
stolen token). Deletion loses that forensic trail.

### Deferred, kept but unused: `ReplacedByTokenHash`
Field exists on `RefreshToken`, linking an old token to its replacement. **Not currently
used** — no cascade-revocation logic reads this chain yet. Decided to keep the field
(cheap to store, avoids a future migration) but explicitly *not* build the chain-walking
"revoke the whole session on detected reuse" logic yet — that's real complexity earned
only if reuse-detection actually becomes a problem in practice.

### Deferred, kept but unused: `GetClaimsAsync` custom claims in JWT
`_userManager.GetClaimsAsync(user)` is called but nothing in the app ever calls
`AddClaimAsync` — so this always returns an empty list right now. Harmless (empty list,
no behavior change), kept for future flexibility (e.g. per-user flags beyond roles) even
though nothing in the PRD currently needs it.

### Deferred: Password reset dev-only stub
`GeneratePasswordResetTokenAsync` only returns the real token in `Development`; returns
null in Production. This means password reset is **non-functional in production** right
now — no email delivery exists to send the token anywhere else. Deliberately kept as a
placeholder: lets the Identity token-generation flow be exercised/tested now, real fix
(email delivery) is a later phase.

### Fixed: Redundant custom claim/env-check duplication
Controller had `_environment.IsDevelopment() && resetToken is not null` — but the service
already guarantees `resetToken` is null outside Development. Removed the redundant
controller-side environment check; `resetToken is not null` alone is sufficient.

### Decision: Custom `ForbiddenException` (403) vs reusing `UnauthorizedAccessException`
Initially considered reusing `UnauthorizedAccessException` for both 401 (not authenticated)
and 403 (authenticated, not permitted) cases — but a single exception type can't map to two
different status codes in the middleware's switch statement. Built a dedicated
`Exceptions/ForbiddenException.cs` once the conflict became concrete, rather than
speculatively up front.

### Decision: `ILogger<T>` via DI, not static `Log.ForContext<T>()`
Generated code initially used Serilog's static global logger directly. Switched to the
standard `ILogger<T>` DI pattern (matching Ecommerce.Api) — more testable, not tied to
Serilog specifically, visible as a constructor dependency instead of a hidden static call.
`builder.Host.UseSerilog()` already bridges all `ILogger<T>` calls to Serilog's sinks, so
nothing was lost by making this switch.

### Decision: Cut duplicate DTOs (`LogoutDto` vs `RefreshTokenRequestDto`, then again for Workspace response DTOs)
Two DTOs with identical shape and no divergent validation aren't earning their existence.
Splitting *later*, exactly when a real requirement forces divergence, costs nothing —
so premature duplication was cut both times it came up.

---

## Phase 2 — Workspaces

### Decision: No `OwnerId` field on `Workspace`; ownership is just `WorkspaceMember.Role == "Owner"`
Keeping both `Workspace.OwnerId` *and* a `WorkspaceMember` row with `Role = "Owner"` creates
two sources of truth that could disagree. Dropped `OwnerId` entirely — single source of
truth, no sync-drift risk. Cost: "who owns this workspace" requires a join/filter query
instead of a direct field read — acceptable tradeoff for correctness.

**Invariant this creates:** a `Workspace` must never exist without at least one
`WorkspaceMember` row (the Owner) — created atomically, same transaction, single
`SaveChangesAsync()` call. Verified this matters concretely: two separate `SaveChangesAsync()`
calls would risk an ownerless workspace if the second insert failed after the first succeeded.

### Deferred cleanup: `WorkspaceMember` has no `AppUser User` navigation property
`WorkspaceMember` has `UserId` (raw FK) but never got the matching `AppUser User { get; set; }`
navigation property — unlike `RefreshToken`, which has both `UserId` and `User`. As a result,
`GetMembersByWorkspaceIdAsync` uses a manual `.Join(_context.Users, ...)` instead of
`.Include(wm => wm.User)` to pull in member names/emails.

**Performance is identical either way** — both `.Include()` and manual `.Join()` compile down
to the same SQL `JOIN`; this is a readability/consistency choice, not a performance one.
Decided to leave the `.Join()` as-is for now to avoid a model change + new migration mid-phase;
revisit by adding the navigation property and simplifying this query, next time this file
is touched or as part of the Phase 2/3 cleanup pass.

### Learned: EF Core navigation properties resolve FK values automatically on save
Tried setting `WorkspaceMember.WorkspaceId = workspace.Id` directly right after
`.Add(workspace)` — but `workspace.Id` is still `0` at that point (`.Add()` doesn't hit the
DB; only `SaveChangesAsync()` does). Fixed by setting the **navigation property**
(`WorkspaceMember.Workspace = workspace`) instead — EF Core's change tracker resolves the
real FK automatically during `SaveChangesAsync()`, inserting the parent first.

---

### Known gap: no "transfer ownership" or "leave workspace" flow
`RemoveMemberFromWorkspaceAsync` correctly blocks an Owner from removing themselves
(`userId == memberId` guard) — this prevents an orphaned workspace with zero Owners, since
every Owner-only check would then fail for everyone. But this means an Owner who wants to
step away currently has no path forward except deleting the whole workspace. Not in MVP
scope (Section 14 doesn't list it) — deferred, add an explicit "transfer ownership" endpoint
later if this becomes a real need.

## Phase 3 — Projects

### Decision: Streamlined to Workspace-Level Access (Removed `ProjectMember` Table)
Initially created a `ProjectMember` join table. However, since Section 5.2 defines a single 2-tier role model (`Owner` / `Member` at workspace level), `ProjectMember` introduced premature complexity and friction without distinct permissions.
- **Removed:** `ProjectMember` table, `ProjectMembers` join queries, and project member endpoints (`GET/POST/DELETE /projects/{id}/members`).
- **Rule:** The **Workspace is the isolation boundary**. All members of a workspace can view, create tasks in, and be assigned tasks in any project within that workspace.
- **Modifications:** Only Workspace Owner or Project Creator (`project.CreatedBy == userId`) can edit or delete a project.

---

## Phase 4 — Tasks & Kanban

### Decision: Enums (`TaskItemStatus`, `TaskItemPriority`) stored as string
Followed the existing `ProjectStatus` pattern: enums are used in application code and validated via FluentValidation `IsEnumName`, but stored as readable strings in PostgreSQL.

### Decision: Dedicated PATCH endpoints for status and assignee
Added `PATCH /tasks/{id}/status` and `PATCH /tasks/{id}/assignee` alongside full `PUT /tasks/{id}`.
- `PATCH /tasks/{id}/status` directly supports Kanban column moves (frontend drag-drop).
- `UpdateTaskRequestDto` (PUT) intentionally omits `Status` to prevent accidental status overwrites during general edits.

### Decision: Unassign tasks on workspace member removal
When a member is removed from a workspace via `DELETE /workspaces/{id}/members/{userId}`, any tasks in that workspace's projects assigned to that user have `AssigneeId` automatically set to `null`.

### Decision: Task assignment requires workspace membership
Assigning a task (`PATCH /tasks/{id}/assignee` or `POST/PUT`) validates that the assignee is an existing member of that workspace.

---

## Open questions / things to revisit later (not urgent)

- **When to split into `Domain` + `Api` or full Clean Architecture:** Now that Phase 4 (MVP backend core loop) is complete, all core domain entities (`User`, `Workspace`, `Project`, `Task`) and relationships exist.
- **Permission-check logic location:** Workspace access checks are implemented per-service. If duplication becomes cumbersome across upcoming features (e.g. comments, activity feed), extract a shared authorization service or policy-based handler.
- **Cascade-revocation on refresh token reuse detection** — deferred, see above.
- **CQRS/MediatR/Vertical Slices** — longer-horizon goal, realistically a Phase 8-equivalent target.