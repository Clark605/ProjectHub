# ProjectHub — Frontend Architecture (Flutter Client)

A technical specification of the Flutter client architecture for **ProjectHub Client** (Mobile & Web).

---

## 1. Architectural Principles

The Flutter client employs a **Feature-First Layered Architecture** with **MVVM + Cubit** state management and the **Repository Pattern**:

```mermaid
graph TD
    subgraph FeatureModule ["Feature Module (e.g. features/kanban/)"]
        subgraph UILayer ["UI Layer"]
            Screen["Views / Screens"]
            Widgets["Private UI Components"]
            Guards["Permission Guards"]
        end

        subgraph LogicLayer ["Logic Layer"]
            Cubit["Feature Cubit (flutter_bloc)"]
            State["Freezed Sealed States"]
        end

        subgraph DataLayer ["Data Layer"]
            Repository["Repository Interface & Implementation"]
            RemoteDataSource["Remote DataSource (Dio)"]
            LocalDataSource["Local DataSource (SecureStorage / Prefs)"]
            Models["Freezed Domain / DTO Models"]
        end
    end

    Screen --> Cubit
    Widgets --> Screen
    Guards --> Screen
    Cubit --> State
    Cubit --> Repository
    Repository --> RemoteDataSource
    Repository --> LocalDataSource
    Models --> Repository
```

---

## 2. Directory Layout & Module Organization

```text
client/
├── assets/
│   ├── fonts/                  # Inter (Regular, Medium, SemiBold, Bold)
│   ├── icons/                  # SVG icons
│   └── images/                 # Onboarding & brand illustrations
├── l10n/
│   ├── app_en.arb              # English localization bundle
│   └── app_ar.arb              # Arabic localization bundle
├── lib/
│   ├── main.dart               # App initialization, native splash & DI setup
│   ├── app.dart                # MaterialApp, AuthGate, theme & routes
│   │
│   ├── core/                   # Cross-cutting foundational services
│   │   ├── constants/          # App constants, API endpoints, storage keys
│   │   ├── di/                 # Dependency injection setup (GetIt + Injectable)
│   │   ├── errors/             # Custom Failure classes & Dio error mapper
│   │   ├── network/            # Resilient Dio client & AuthInterceptor
│   │   ├── routes/             # AppRouter (onGenerateRoute) & RouteNames
│   │   ├── storage/            # FlutterSecureStorage & SharedPreferences
│   │   ├── theme/              # Stitch UI tokens & Material 3 ThemeData
│   │   ├── utils/              # PermissionChecker, date utilities, validators
│   │   └── widgets/            # Reusable UI atoms (buttons, cards, chips, dialogs)
│   │
│   └── features/               # Feature-First Modules
│       ├── splash/             # Startup & token verification
│       ├── onboarding/         # First-launch onboarding carousel
│       ├── auth/               # Login, Register, Profile screens & Cubits
│       ├── workspaces/         # Workspaces list, switcher & member management
│       ├── projects/           # Projects dashboard & project creation
│       └── kanban/             # Kanban board, columns, drag-drop & task sheets
```

---

## 3. Dependency Injection & Service Locator

The application uses **`get_it`** and **`injectable`** for automated dependency registration:

```dart
// lib/core/di/injection.dart
final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();
```

---

## 4. Resilient Network Layer (`AuthInterceptor`)

The network layer provides transparent token refreshing for expired JWT tokens:

```mermaid
sequenceDiagram
    participant Cubit as Feature Cubit
    participant Dio as Dio HTTP Client
    participant Interceptor as AuthInterceptor
    participant API as ASP.NET Core API

    Cubit->>Dio: Request API resource
    Dio->>Interceptor: Inject Bearer Token
    Interceptor->>API: HTTP Request
    API-->>Interceptor: 401 Unauthorized (JWT Expired)
    Note over Interceptor: Enqueue pending requests & lock queue
    Interceptor->>API: POST /auth/refresh { refreshToken }
    API-->>Interceptor: 200 OK { token, refreshToken }
    Note over Interceptor: Persist new tokens to SecureStorage & unlock queue
    Interceptor->>API: Replay failed request with new token
    API-->>Dio: 200 OK (Response Payload)
    Dio-->>Cubit: Emit successful state
```

---

## 5. Responsive UI Strategy

The client dynamically switches layout structures across breakpoints:

```mermaid
graph LR
    Viewport["Viewport Width"] -->|< 768px| Mobile["Mobile: BottomNav + Swipeable PageView Columns + BottomSheet"]
    Viewport -->|768px - 1199px| Tablet["Tablet: NavigationRail + 2-Column Grid + Centered Modal"]
    Viewport -->|>= 1200px| Desktop["Desktop/Web: Fixed 240px Sidebar + Full Kanban Board + Slide-over Sheet"]
```

---

## 6. Stitch Design System & Theming

Designed in accordance with Material 3, using custom Stitch UI tokens:

- **Foundation Background:** Deep Slate `#0F172A`
- **Surface Elevation:** `#13131B` and Container `#1E293B`
- **Primary Brand:** Indigo `#6366F1`
- **Secondary Accent:** Sky Blue `#38BDF8`
- **Priority Colors:**
  - `Urgent`: Rose `#FB7185`
  - `High`: Coral `#F43F5E`
  - `Medium`: Sky `#38BDF8`
  - `Low`: Slate `#94A3B8`
- **Typography:** Bundled **Inter** font family (`assets/fonts/`) for zero font flicker (FOIT).

