# ProjectHub Polyglot Monorepo

Polyglot Monorepo containing the **ASP.NET Core Web API** backend and the **Flutter** Web & Mobile frontend.

---

## 📁 Repository Structure

```
ProjectHub/
├── .github/
│   └── workflows/
│       ├── server.yml          # CI for .NET backend (triggers on server/**)
│       └── client.yml          # CI for Flutter frontend (triggers on client/**)
├── .vscode/
│   ├── launch.json             # Compound F5 multi-target debugging configurations
│   └── tasks.json              # Build tasks
├── scripts/
│   ├── build-all.ps1           # Builds both server & client
│   └── run-dev.ps1             # Runs API with dotnet watch and starts Flutter
├── server/                     # .NET 10.0 Web API
│   ├── ProjectHub.Api.sln
│   └── ProjectHub.Api/
└── client/                     # Flutter Client (Android, iOS, Web)
    ├── pubspec.yaml
    └── lib/
```

---

## 🚀 Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (channel stable)
- [Visual Studio Code](https://code.visualstudio.com/) (recommended) with:
  - C# Dev Kit / C# extension
  - Flutter & Dart extensions

---

## 💻 Local Development

### Option A: VS Code Multi-Target Debugging (Recommended)
1. Open the root workspace in VS Code.
2. Go to the **Run and Debug** tab (`Ctrl+Shift+D`).
3. Select **`Full Stack (Server + Client)`** and press `F5`.
   - VS Code will compile and start the .NET API (attaching the debugger) and simultaneously launch the Flutter client with hot reload.

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
flutter analyze
flutter test
```

---

## 🔄 CI/CD Workflows

GitHub Actions workflows are configured with path filtering so builds run independently:
- Changes in `server/**` trigger `.github/workflows/server.yml`
- Changes in `client/**` trigger `.github/workflows/client.yml`

