---
trigger: model_decision
---

# Commit Message Instructions

Generate structured **Conventional Commits** for the **ProjectHub** monorepo (ASP.NET Core 10 API + Flutter Client).

---

## Format

```text
<type>(<end>/<scope>): <imperative subject (max 72 chars, no period)>

- <Bullet point detailing what changed>
- <Technical detail: classes, cubits, endpoints, or migrations>
- <Rationale, edge cases, or breaking change notes>

<Optional closing summary of impact/value>
```

> **Note:** For general changes on an end, use `<type>(server):` or `<type>(client):`. For cross-cutting repo tooling/docs, use `docs`, `ci`, or `scripts`.

---

## Types & Scopes

| Type | When to Use |
| :--- | :--- |
| `feat` | New feature or API endpoint |
| `fix` | Bug fix or error resolution |
| `refactor` | Code restructuring without behavioral changes |
| `perf` | Performance optimization or caching |
| `test` | Adding or updating tests (unit, widget, integration) |
| `docs` | Documentation, PRD, or architecture updates |
| `chore` | Build scripts, dependencies, CI/CD, configs |
| `style` | Formatting, linting, whitespace |

### Scopes by End
- **Server (`server`):** `server/auth`, `server/workspaces`, `server/projects`, `server/tasks`, `server/cache`, `server/db`, or `server`
- **Client (`client`):** `client/auth`, `client/workspaces`, `client/projects`, `client/kanban`, `client/network`, `client/theme`, `client/router`, `client/l10n`, or `client`
- **Cross-cutting:** `docs`, `ci`, `scripts`

---

## Rules
1. **Specify Target End in Title:** Always identify the end (`server` or `client`) in the scope prefix (e.g. `feat(client/kanban):` or `fix(server/auth):`).
2. **Imperative Subject:** Use present-tense imperative mood (e.g. `add`, `fix`, `refactor` — not `added`, `fixes`).
3. **Subject Length:** Maximum 72 characters, lowercase type/scope, no trailing period.
4. **Atomic Focus:** One logical change per commit message.
5. **Body Bullets:** Detail the *what* and *why* with specific symbols/files changed.
6. **Breaking Changes:** Prefix with `⚠️ BREAKING:` or `BREAKING CHANGE:`.

---

## Examples

### Frontend Feature
```text
feat(client/kanban): add drag-and-drop column transitions

- Implement DragTarget and Draggable widgets for Kanban cards
- Integrate KanbanCubit.updateTaskStatus() with optimistic state update
- Add PATCH /tasks/{id}/status API call via TaskRepository

Enables interactive task lifecycle movement matching board designs.
```

### Backend Bug Fix
```text
fix(server/auth): resolve refresh token race condition

- Add row-level lock during token rotation in RefreshTokenRepository
- Prevent concurrent token reuse false-positives
- Return 401 Unauthorized with token_expired code
```