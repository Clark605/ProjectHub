# ProjectHub — Commit Message Instructions

Use **structured, conventional commit messages** for all commits in the **ProjectHub** polyglot monorepo (ASP.NET Core 10 Web API + Flutter Client).

---

## 📋 Commit Message Format

```text
type(scope): concise imperative subject line (max 72 chars)

- Bullet point explaining what was changed or added
- Technical detail (classes, controllers, cubits, services, migrations)
- Impact, architecture rationale, or edge case handled
- Test coverage or breaking change notice (if applicable)

Brief closing sentence explaining the value or purpose.
```

---

## 🏷 Valid Types

| Type | Description | Example Scopes |
| :--- | :--- | :--- |
| `feat` | A new user-facing feature or API capability | `auth`, `workspaces`, `projects`, `tasks`, `kanban` |
| `fix` | A bug fix or error resolution | `auth`, `kanban`, `client`, `server` |
| `refactor`| Code refactoring without behavioral changes | `services`, `cubit`, `data`, `router` |
| `perf` | Performance optimizations or caching | `cache`, `server`, `client`, `db` |
| `test` | Adding or updating unit, widget, or integration tests | `server`, `client`, `auth`, `tasks` |
| `docs` | Documentation, PRD, architecture log, or README updates | `docs`, `readme`, `api` |
| `chore` | Build scripts, CI/CD workflows, dependencies, configs | `ci`, `scripts`, `deps`, `vscode` |
| `style` | Formatting, whitespace, lint fixes (no code logic change)| `client`, `server` |

---

## 🎯 Scopes for ProjectHub

### Monorepo & Cross-Cutting
- `server` — General .NET API backend changes
- `client` — General Flutter frontend changes
- `docs` — Root `docs/` folder, PRD, architecture specs
- `ci` — GitHub Actions workflows (`.github/workflows/`)
- `scripts` — Monorepo PowerShell automation scripts (`scripts/`)

### Backend (`server/ProjectHub.Api`)
- `auth` — ASP.NET Core Identity, JWT generation, RefreshToken rotation
- `workspaces` — Workspace CRUD, membership, role-based authorization (Owner/Member)
- `projects` — Project CRUD, status lifecycle, workspace scoping
- `tasks` — Task CRUD, Kanban status PATCH, assignee PATCH
- `cache` — HybridCache (L1 in-memory + L2 Redis)
- `db` — EF Core DbContext, PostgreSQL models, migrations

### Frontend (`client/`)
- `auth` — AuthCubit, LoginScreen, RegisterScreen, AuthGate
- `workspaces` — WorkspaceSelectorScreen, WorkspaceCubit, member dialogs
- `projects` — ProjectsDashboardScreen, ProjectCubit
- `kanban` — KanbanScreen, KanbanCubit, column drag-drop, mobile swipe
- `network` — Dio client, AuthInterceptor, token refresh queue
- `theme` — Stitch UI tokens, dark/light themes, Inter font assets
- `router` — AppRouter (`onGenerateRoute`), navigation guards
- `l10n` — Localization ARB files (English / Arabic)

---

## ✍️ Rules & Best Practices

1. **Imperative Subject Line:** Write in the imperative mood (e.g., `add ...`, `implement ...`, `fix ...`, `refactor ...` — NOT `added ...` or `fixing ...`).
2. **Character Limit:** Keep the subject line under 72 characters.
3. **Atomic Commits:** Each commit should represent one logical unit of work.
4. **Detail the "Why":** Use bullet points to explain the technical details and rationale.
5. **Highlight Breaking Changes:** Prefix critical breaking changes with `⚠️ BREAKING:` in the body.

---

## 💡 Examples for ProjectHub

### ✅ Feature Addition (Backend)

```text
feat(auth): implement refresh token rotation with SHA256 hashing

- Add dedicated RefreshToken entity with IsUsed theft detection flag
- Hash raw 64-byte tokens with SHA256 before database persistence
- Add POST /auth/refresh endpoint for rotating expired access tokens
- Inject multi-session support linked to AppUser

Ensures secure, persistent multi-device sessions across Web and Mobile.
```

### ✅ Feature Addition (Frontend)

```text
feat(kanban): add drag-and-drop column status transitions

- Implement DragTarget and Draggable widgets for Kanban cards
- Integrate KanbanCubit.updateTaskStatus() with optimistic UI updates
- Add PATCH /tasks/{id}/status API integration via TaskRepository
- Handle rollback state with snackbar on network failure

Delivers interactive task lifecycle movement matching desktop & mobile boards.
```

### ✅ Bug Fix (Backend)

```text
fix(workspaces): cascade unassign tasks on workspace member removal

- Update RemoveMemberFromWorkspaceAsync to query assigned tasks
- Automatically set AssigneeId to null for tasks assigned to removed user
- Prevent orphaned assignee foreign key references
- Return 204 NoContent upon successful member removal

Prevents data inconsistency when a removed member had active task assignments.
```

### ✅ Bug Fix (Frontend)

```text
fix(network): resolve token refresh deadlock in AuthInterceptor

- Add request queue locking while POST /auth/refresh is in-flight
- Replay queued requests with new Bearer token upon successful refresh
- Clear secure storage and emit AuthState.unauthenticated on refresh failure
- Fix intermittent 401 loop on concurrent expired API calls

Eliminates session dropouts during rapid parallel network requests.
```

### ✅ Refactoring / Performance

```text
perf(server): integrate HybridCache with Redis L2 for user profile

- Replace direct DB query in UsersController.GetMe with HybridCache
- Configure 5-min L1 local cache and 15-min L2 Redis expiration
- Add tag-based cache eviction on PUT /users/me updates
- Reduce redundant database reads on hot profile endpoints

Improves profile retrieval latency from ~15ms to sub-millisecond in memory.
```

### ✅ Documentation

```text
docs: create global documentation hub and REST API specification

- Add docs/README.md with full-stack Mermaid system architecture
- Create docs/api-reference.md covering all REST endpoints & DTOs
- Add docs/backend-architecture.md and docs/frontend-architecture.md
- Update root README.md with quick navigation links

Provides clear onboarding and architectural reference for the entire monorepo.
```

---

## ❌ Anti-Patterns to Avoid

```text
❌ wip
❌ fix bugs
❌ update files
❌ feat: changes to server and client and fixed some stuff
```