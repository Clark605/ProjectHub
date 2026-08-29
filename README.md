# ProjectHub Polyglot Monorepo

Polyglot Monorepo containing the **ASP.NET Core 10 Web API** backend and the **Flutter (Mobile & Web)** frontend for **ProjectHub** — a collaborative project management and Kanban platform.

---

## 📚 Central Documentation

Detailed architectural specifications, API schemas, design decisions, and setup guides are available in the **[`docs/`](./docs/README.md)** directory:

- 📖 **[Documentation Hub](./docs/README.md)** — Central documentation index & system overview.
- 📋 **[Product Requirements Document (PRD)](./docs/prd.md)** — Core product goals, user roles & roadmap.
- 🏛 **[Architecture & Decision Log](./docs/architecture-log.md)** — Rationale behind architectural choices & tradeoffs.
- ⚙️ **[Backend Architecture Guide](./docs/backend-architecture.md)** — .NET 10 API, EF Core data model, caching & security.
- 🎨 **[Frontend Architecture Guide](./docs/frontend-architecture.md)** — Flutter Feature-First MVVM, Cubit state management & Stitch tokens.
- 📡 **[REST API Reference](./docs/api-reference.md)** — Endpoints, auth mechanisms, and JSON payloads.
- 🛠 **[Full-Stack Setup Guide](./docs/setup-guide.md)** — Step-by-step developer onboarding & environment configuration.

---

## 📁 Repository Structure

```text
ProjectHub/
├── .github/
│   └── workflows/
│       ├── server.yml          # CI for .NET backend (triggers on server/**)
│       └── client.yml          # CI for Flutter frontend (triggers on client/**)
├── .vscode/
│   ├── launch.json             # Compound F5 multi-target debugging configurations
│   └── tasks.json              # Build tasks
├── docs/                       # Global project documentation hub
│   ├── README.md               # Documentation index & architecture diagram
│   ├── prd.md                  # Product Requirements Document
│   ├── architecture-log.md     # Architecture decisions & judgment log
│   ├── backend-architecture.md # ASP.NET Core 10 technical specification
│   ├── frontend-architecture.md# Flutter Client technical specification
│   ├── api-reference.md        # Comprehensive REST API contracts
│   └── setup-guide.md          # Full-stack developer onboarding & setup
├── scripts/
│   ├── build-all.ps1           # Builds and validates both server & client
│   └── run-dev.ps1             # Runs API with dotnet watch and starts Flutter
├── server/                     # [Read Server Documentation](server/README.md)
│   ├── ProjectHub.Api.sln
│   └── ProjectHub.Api/         # ASP.NET Core 10 Web API project
└── client/                     # [Read Client Documentation](client/README.md)
    ├── pubspec.yaml
    └── lib/                    # Flutter cross-platform client (Mobile & Web)
```

---

## 🚀 Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (channel stable)
- [PostgreSQL](https://www.postgresql.org/download/) (or Docker)
- [Visual Studio Code](https://code.visualstudio.com/) (recommended) with:
  - C# Dev Kit / C# extension
  - Flutter & Dart extensions

---

## 💻 Local Development

### Option A: VS Code Multi-Target Debugging (Recommended)
1. Open the root workspace in VS Code.
2. Go to the **Run and Debug** tab (`Ctrl+Shift+D`).
3. Select **`Full Stack (Server + Client)`** and press `F5`.
   - VS Code will compile and start the .NET API (attaching the debugger, opening Swagger UI) and simultaneously launch the Flutter client with hot reload.

### Option B: PowerShell Dev Script
From the repository root:
```powershell
.\scripts\run-dev.ps1
```

### Option C: Manual CLI

**1. Start .NET Server:**
```powershell
cd server/ProjectHub.Api
dotnet watch run
```
- Swagger UI will be available at: `http://localhost:5259/swagger` or `https://localhost:7125/swagger`.

**2. Start Flutter Client:**
```powershell
cd client
flutter run -d chrome     # For Web
# or
flutter run              # For connected Android/iOS device or emulator
```

---

## 🔨 Build & Verification

To verify the entire monorepo:
```powershell
.\scripts\build-all.ps1
```

Or individually:
```powershell
# Backend
dotnet build server/ProjectHub.Api.sln

# Client
cd client
flutter pub get
flutter analyze
flutter test
```

---

## 🔄 CI/CD Workflows

GitHub Actions workflows are configured with path filtering so builds run independently:
- Changes in `server/**` trigger `.github/workflows/server.yml`
- Changes in `client/**` trigger `.github/workflows/client.yml`
