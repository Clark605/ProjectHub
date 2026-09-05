# Agent Guidelines

## Agent skills

### Issue tracker

Issues and specs live on GitHub Issues and are managed via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical triage roles mapped to repository label strings (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (`CONTEXT.md` at repo root and ADRs in `docs/adr/`). See `docs/agents/domain.md`.

## Context Pointers

Consult these authoritative documents when working in specific areas:

- **Domain Glossary**: Read [CONTEXT.md](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/CONTEXT.md) for canonical terminology and forbidden synonyms before naming entities, endpoints, or features.
- **Architectural Decisions**: Read [docs/adr/](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/docs/adr/) for hard-to-reverse decisions before proposing structural or boundary changes.
- **Product Scope & Phase Gates**: Read [docs/prd.md](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/docs/prd.md) when evaluating requirements, user roles, or feature boundaries.
- **Backend Architecture (.NET 10)**: Read [docs/backend-architecture.md](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/docs/backend-architecture.md) when editing ASP.NET Core controllers, services, caching, or EF Core models.
- **Frontend Architecture (Flutter)**: Read [docs/frontend-architecture.md](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/docs/frontend-architecture.md) when building screens, Cubits, repositories, or network interceptors.
- **Design Tokens & Theming**: Read [docs/design-system.md](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/docs/design-system.md) when styling widgets, selecting colors, or setting typography.
- **REST Endpoints & Payloads**: Read [docs/api-reference.md](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/docs/api-reference.md) when crafting HTTP requests or updating API DTO contracts.
- **Navigation & UX Journeys**: Read [docs/user-flow.md](file:///d:/MyProgrammingProjects/DotnetProjects/ProjectHub.Api/docs/user-flow.md) when modifying routing, dialogs, zero-states, or workspace switching flows.
