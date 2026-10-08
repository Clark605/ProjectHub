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

- **Domain Glossary**: Read [CONTEXT.md](CONTEXT.md) for canonical terminology and forbidden synonyms before naming entities, endpoints, or features.
- **Architectural Decisions**: Read [docs/adr/](docs/adr/) for hard-to-reverse decisions before proposing structural or boundary changes.
- **Product Scope & Phase Gates**: Read [docs/prd.md](docs/prd.md) when evaluating requirements, user roles, or feature boundaries.
- **Backend Architecture (.NET 10)**: Read [docs/backend-architecture.md](docs/backend-architecture.md) when editing ASP.NET Core controllers, services, caching, or EF Core models.
- **Database Schema**: Read [docs/database-schema.md](docs/database-schema.md) for tables, columns, indexes, foreign keys, cascades, and PostgreSQL smallint enums.
- **Frontend Architecture (Flutter)**: Read [docs/frontend-architecture.md](docs/frontend-architecture.md) when building screens, Cubits, repositories, or network interceptors.
- **Design Tokens & Theming**: Read [docs/design-system.md](docs/design-system.md) when styling widgets, selecting colors, or setting typography.
- **REST Endpoints & Payloads**: Read [docs/api-reference.md](docs/api-reference.md) when crafting HTTP requests or updating API DTO contracts.
- **Navigation & UX Journeys**: Read [docs/user-flow.md](docs/user-flow.md) when modifying routing, dialogs, zero-states, or workspace switching flows.
- **Core Reusable Components**: Read [.agents/rules/flutter-core-reusable-components.md](.agents/rules/flutter-core-reusable-components.md) and [client/lib/core/](client/lib/core/) for mandatory usage of SafeActionCubit, standardized widgets, error states, bottom sheets, and dialogs.
