# ProjectHub Documentation Hub

Welcome to the centralized documentation hub for **ProjectHub** — a modern, collaborative project and task management platform built as a monorepo with an **ASP.NET Core 10 Web API** backend and a **Flutter (Mobile & Web)** client.

---

## 📚 Documentation Index

### 1. Domain & Architectural Decisions
| Document | Description |
| :--- | :--- |
| **[Domain Glossary (CONTEXT.md)](../CONTEXT.md)** | Single source of truth for domain vocabulary, canonical definitions, and forbidden synonyms. |
| **[Architecture Decision Records (ADRs)](./adr/)** | 18 sequenced records of hard-to-reverse architectural decisions, tradeoffs, and rationale. |
| **[Architecture & Decision Index](./architecture-log.md)** | Chronological index mapping project phases to formal ADRs (ADR-0001 through ADR-0018). |

### 2. Product Specs & User Experience
| Document | Description |
| :--- | :--- |
| **[Product Requirements Document (PRD)](./prd.md)** | MVP scope, two-tier user roles, roadmap phases (Phases 0–7 completed), and post-MVP stability gates. |
| **[User Flows & Journeys](./user-flow.md)** | Post-login user journeys, real-time collaboration, routing logic, navigation architecture, and responsive UX states. |
| **[Design System Specification](./design-system.md)** | Stitch Deep Slate token architecture, color maps, typography, and component specs. |

### 3. Engineering Architecture Deep Dives
| Document | Description |
| :--- | :--- |
| **[Backend Architecture (.NET 10)](./backend-architecture.md)** | ASP.NET Core API design, SignalR real-time hub, PostgreSQL smallint enums, JWT security, and resilient HybridCache. |
| **[Database Schema Specification](./database-schema.md)** | PostgreSQL 16 schema, tables, fields, constraints, composite indexes, cascades, enums, and ER diagram. |
| **[Frontend Architecture (Flutter)](./frontend-architecture.md)** | Flutter Clean Architecture (Presentation + Data, <200 lines/file), Cubits, SignalR service, and Stitch tokens. |
| **[REST & Real-Time API Reference](./api-reference.md)** | Complete endpoint specifications, SignalR hub contracts, request/response schemas, and authentication flow. |

### 4. Setup & Agent Configuration
| Document | Description |
| :--- | :--- |
| **[Full-Stack Setup Guide](./setup-guide.md)** | Step-by-step developer onboarding, database migrations, secrets, and debugging. |
| **[Agent Guidelines & Pointers](../AGENTS.md)** | High-priority agent context pointers and skill triggers. |
| **[Agent Workflow Config](./agents/)** | Issue tracker conventions, triage label vocabulary, and domain doc consumption rules. |

---

## 🏛 System Architecture Overview

```mermaid
graph TB
    subgraph Clients ["Frontend Layer (Flutter 3.x)"]
        Web["Flutter Web (Widescreen Dashboard)"]
        Mobile["Flutter Mobile (Android & iOS)"]
    end

    subgraph Gateway ["Networking & Real-Time Security"]
        Dio["Dio HTTP Client + AuthInterceptor"]
        SignalRClient["SignalR Client (WebSocket Transport)"]
    end

    subgraph Backend ["Backend Layer (.NET 10 Web API)"]
        API["ASP.NET Core Controllers (/api/v1)"]
        Hub["SignalR WorkspaceHub (/api/v1/hubs/workspace)"]
        Middleware["ExceptionHandlingMiddleware & Serilog"]
        Services["Domain & Application Services (Atomic Task/Tag)"]
        Identity["ASP.NET Core Identity (AppUser)"]
        EF["Entity Framework Core 10 (Npgsql Smallint Enums)"]
        Cache["HybridCache (L1 Memory + L2 Redis)"]
    end

    subgraph Storage ["Persistence & Infrastructure"]
        Postgres[(PostgreSQL 16 Database)]
        Redis[(Redis 7 Distributed Cache & Pub/Sub)]
    end

    Web --> Dio
    Web --> SignalRClient
    Mobile --> Dio
    Mobile --> SignalRClient
    Dio -->|HTTPS + JWT Bearer| Middleware
    SignalRClient -->|WSS + JWT Token| Hub
    Middleware --> API
    API --> Services
    Services --> Hub
    Services --> Identity
    Services --> EF
    Services --> Cache
    Hub --> Redis
    EF --> Postgres
    Cache --> Redis
```

---

## 🚀 Quick Links & Repositories

- **Root Workspace:** [ProjectHub Monorepo Root](../README.md)
- **Backend Project:** [.NET 10 API README](../server/README.md)
- **Frontend Project:** [Flutter Client README](../client/README.md)
- **Automation Scripts:** [Local Dev & Build Scripts](../scripts/)
- **CI/CD Pipelines:** [GitHub Actions Workflows](../.github/workflows/)
