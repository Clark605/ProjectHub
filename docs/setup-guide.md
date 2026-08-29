# ProjectHub — Full-Stack Setup & Local Development Guide

Complete guide for configuring your local development environment, provisioning the database, applying migrations, and launching both backend and frontend applications.

---

## 📋 Prerequisites

Ensure the following tools are installed on your workstation:

| Tool | Recommended Version | Download / Install |
| :--- | :--- | :--- |
| **.NET SDK** | .NET 10.0+ | [Download .NET](https://dotnet.microsoft.com/download) |
| **Flutter SDK** | 3.x (Stable channel) | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| **PostgreSQL** | 15+ or Docker | [PostgreSQL Downloads](https://www.postgresql.org/download/) |
| **Redis** *(Optional)* | 7.x or Docker | [Redis Downloads](https://redis.io/download/) |
| **VS Code** *(Recommended)* | Latest | Extensions: *C# Dev Kit*, *Flutter*, *Dart* |

---

## 🗄 1. Infrastructure Setup (Docker / Local Services)

### Running PostgreSQL and Redis via Docker

```powershell
# Run PostgreSQL container
docker run --name projecthub-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=ProjectHubDb -p 5432:5432 -d postgres:latest

# Run Redis container (optional for L2 caching)
docker run --name projecthub-redis -p 6379:6379 -d redis:alpine
```

---

## ⚙ 2. Backend Configuration (.NET 10 API)

1. **Install the EF Core global tool:**
   ```powershell
   dotnet tool install --global dotnet-ef
   ```

2. **Configure User Secrets:**
   ```powershell
   cd server/ProjectHub.Api
   dotnet user-secrets init
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=ProjectHubDb;Username=postgres;Password=postgres"
   dotnet user-secrets set "ConnectionStrings:Redis" "localhost:6379,abortConnect=false"
   dotnet user-secrets set "Jwt:Key" "super_secret_jwt_key_at_least_32_characters_long_12345"
   dotnet user-secrets set "Jwt:Issuer" "ProjectHub.Api"
   dotnet user-secrets set "Jwt:Audience" "ProjectHub.Client"
   ```

3. **Apply Database Migrations:**
   ```powershell
   dotnet ef database update
   ```

---

## 📱 3. Frontend Configuration (Flutter Client)

1. **Install dependencies:**
   ```powershell
   cd client
   flutter pub get
   ```

2. **Run Code Generation (Freezed, Injectable, JSON):**
   ```powershell
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Verify Flutter Setup:**
   ```powershell
   flutter doctor
   ```

---

## 🚀 4. Running the Entire Application

### Option A: VS Code Multi-Target Compound Debugging (Recommended)

1. Open the repository root in Visual Studio Code.
2. Press `Ctrl+Shift+D` to open the **Run & Debug** pane.
3. Choose **`Full Stack (Server + Client)`** from the dropdown.
4. Press `F5`. VS Code will:
   - Compile and launch the .NET API with debugging attached.
   - Automatically open the Swagger UI browser window.
   - Start the Flutter client with hot reload enabled.

### Option B: PowerShell Automation Script

From the repository root:
```powershell
.\scripts\run-dev.ps1
```

### Option C: Manual Terminal Execution

**Terminal 1 — Backend:**
```powershell
cd server/ProjectHub.Api
dotnet watch run
```

**Terminal 2 — Frontend:**
```powershell
cd client
# Run for Web:
flutter run -d chrome

# Or run for Mobile emulator:
flutter run
```

---

## 🔨 5. Verification & Testing

To verify the entire monorepo builds and passes analysis:

```powershell
.\scripts\build-all.ps1
```

Or individually:

```powershell
# Test Backend
dotnet build server/ProjectHub.Api.sln

# Test Frontend
cd client
flutter analyze
flutter test
```

---

## ❓ 6. Common Troubleshooting

| Issue | Root Cause | Resolution |
| :--- | :--- | :--- |
| `Cannot connect to PostgreSQL` | Database service stopped or wrong port | Verify `docker ps` or local service is running on port 5432. |
| `Jwt:Key is not configured` | Missing user secrets | Run `dotnet user-secrets set "Jwt:Key" "..."` in `server/ProjectHub.Api`. |
| `Freezed missing .freezed.dart` | Build runner has not been executed | Run `dart run build_runner build --delete-conflicting-outputs` in `client/`. |
| `CORS Error on Flutter Web` | Backend origin restrictions | Ensure `app.UseCors()` allows the Flutter Web host origin in development. |

