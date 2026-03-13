# Architecture Guide

## High-level approach

The project uses a pragmatic Clean Architecture style:

- `presentation`: UI + BLoC state management
- `domain`: entities, repository contracts, use cases
- `data`: repository implementations, local/remote datasources, models

The app is local-first for core feature data (campaigns, coupons, loyalty, notifications):

1. Load cached local data.
2. Try remote sync.
3. Update local DB.
4. Return synced data, or fallback to cache on remote failure.

## Workspace packages

Defined in root `pubspec.yaml` workspace:

- `packages/app_core`
  - `Result`, `Either`, `Failure`, `Exception`, `UseCase`, `ResultBloc`
- `packages/app_logger`
  - `talker` wrapper, scoped logger, logger mixin
- `packages/app_network`
  - `ApiClient`, `DioFactory`, auth interceptor, token store contracts/impl
- `packages/app_storage`
  - `SharedPreferencesService`, `SecureStorageService`
- `packages/app_ui_kit`
  - shared theme/tokens

## App structure

```text
lib/
  app/
    bootstrap/
    config/
    di/
      modules/
    router/
    auth/access/
  core/
    database/
  features/
    <feature>/
      data/
      di/
      domain/
      presentation/
```

## Diagrams

- Strategy: `docs/diagrams/strategy.mmd`
- Structure: `docs/diagrams/structure.mmd`
- Architecture: `docs/diagrams/architecture.mmd`
- Auth access control: `docs/diagrams/auth_access.mmd`
- Config + bootstrap: `docs/diagrams/config_bootstrap.mmd`
- Bootstrap flow: `docs/diagrams/bootstrap_flow.mmd`
- Local-first sync: `docs/diagrams/local_first_sync.mmd`

### Strategy

```mermaid
flowchart TD
  A["App launch"] --> B["Bootstrap"]
  B --> C["Configure dependencies"]
  C --> D["Locale controller (persisted)"]
  B --> E["Router"]
  E --> F["Auth access strategy"]
  F -->|"Requires auth"| G["Auth flow"]
  F -->|"Allowed"| H["Feature navigation"]

  H --> I["BLoC"]
  I --> J["Use case"]
  J --> K["Repository"]
  K --> L["Local cache (Drift)"]
  K --> M["Remote API (Dio)"]
  M --> L
  L --> I
```

### Structure

```mermaid
flowchart TB
  subgraph Repo["Repository"]
    R1["lib/"]
    R2["packages/"]
    R3["docs/"]
    R4["scripts/"]
  end

  subgraph Lib["lib/"]
    L1["app/"]
    L2["core/"]
    L3["features/"]
    L4["l10n/"]
  end

  subgraph Features["lib/features/"]
    F1["auth/"]
    F2["campaigns/"]
    F3["coupons/"]
    F4["loyalty/"]
    F5["notifications/"]
    F6["rewards/"]
    F7["more/"]
  end

  subgraph FeatureShape["feature shape"]
    S1["data/"]
    S2["domain/"]
    S3["presentation/"]
    S4["di/"]
  end

  subgraph Packages["packages/"]
    P1["app_core"]
    P2["app_logger"]
    P3["app_network"]
    P4["app_storage"]
    P5["app_ui_kit"]
  end

  R1 --> Lib
  R2 --> Packages
  L3 --> Features
  F1 --> FeatureShape
```

### Bootstrap flow

```mermaid
flowchart TD
  A["bootstrap(...)"] --> B["runZonedGuarded"]

  B --> C["WidgetsFlutterBinding.ensureInitialized"]
  C --> D["Configure framework error hooks"]
  D --> E["Register font licenses"]
  E --> F["Build StartupTask list"]
  F --> G["StartupRunner.runCritical"]
  G --> H["runApp(builder)"]
  H --> I["StartupRunner.runDeferred (parallel)"]

  G --> G1["configureDependencies (critical)"]
  G --> G2["seedLocalSampleData (optional)"]

  B --> Z["Zone error handler"]
  Z --> Z1["StartupLogger.error"]
  Z --> Z2["FlutterError.presentError (debug only)"]
```

### Architecture

```mermaid
flowchart LR
  UI["UI (pages/widgets)"] --> BLOC["BLoC"]
  BLOC --> UC["Use case"]
  UC --> REPO["Repository"]
  REPO --> LDS["Local datasource"]
  REPO --> RDS["Remote datasource"]
  RDS --> API["APIService/Dio"]
  LDS --> DB["Drift DB"]

  REPO -. "returns Result<T>" .-> BLOC

  subgraph Domain["Domain layer"]
    UC
    REPO
  end

  subgraph Data["Data layer"]
    LDS
    RDS
  end

  subgraph Presentation["Presentation layer"]
    UI
    BLOC
  end
```

### Auth Access Control

```mermaid
flowchart TD
  A["Navigation request"] --> B["AppRouter"]
  B --> C["AuthConfig"]

  C -->|"mandatory login"| D["Check AuthService/AuthBloc session"]
  D -->|"guest"| E["Redirect to /login?from=..."]
  D -->|"authenticated"| H["Allow route"]

  C -->|"optional login"| F["Allow route"]
  F --> G["Protected screen?"]
  G -->|"no"| H
  G -->|"yes"| I["LoginRequiredWrapper"]
  I -->|"guest"| J["Show in-place login"]
  I -->|"authenticated"| H
```

### Config And Bootstrap

```mermaid
flowchart TD
  A["Process start"] --> B["AppConfig.fromEnvironment"]
  B --> C["Resolve define (dart-define)"]
  C --> D["Resolve envied (.env)"]
  D --> E["Fallback defaults"]

  A --> F["bootstrap()"]
  F --> G["WidgetsFlutterBinding.ensureInitialized"]
  F --> H["configureDependencies"]
  H --> I["AppCoreModule"]
  I --> J["AppLocaleController"]
  H --> K["Feature modules"]
  F --> L["runApp"]
  F --> M["seedLocalSampleData (optional)"]
```

### Local-First Sync

```mermaid
sequenceDiagram
  participant UI
  participant BLoC
  participant UseCase
  participant Repo
  participant Local
  participant Remote

  UI->>BLoC: request data
  BLoC->>UseCase: execute()
  UseCase->>Repo: get()
  Repo->>Local: getCached()
  Local-->>Repo: cached items

  Repo->>Remote: fetch()
  alt remote success
    Remote-->>Repo: items
    Repo->>Local: save(items)
    Local-->>Repo: ok
    Repo-->>UseCase: synced items
  else remote failure
    Repo-->>UseCase: cached items (if any) or failure
  end

  UseCase-->>BLoC: Result<T>
  BLoC-->>UI: state update
```

## Dependency direction

Allowed direction inside a feature:

- `presentation -> domain`
- `data -> domain`
- `domain -> (none of data/presentation)`

Cross-feature coupling should be avoided. Shared cross-cutting concerns should go through `app_core`, `app_logger`, `app_network`, `app_storage`, or a dedicated reusable package.

Localization is handled via Flutter gen-l10n; see `docs/localization.md`.

## Startup lifecycle

Entry points call `bootstrap(...)`.

Critical startup tasks:

- `configureDependencies(...)`

Deferred/conditional startup tasks:

- `seedLocalSampleData()` based on config

Startup is wrapped with `runZonedGuarded`, and framework/platform errors are logged through `StartupLogger` + `AppLogger`.

## Configuration precedence

Runtime config values are resolved in this order:

1. `--dart-define`
2. `.env` (via `envied`)
3. built-in defaults in `AppConfig`

This keeps CI/release overrides explicit while allowing local contributor setup from `.env`.

## Dependency injection

`get_it` is orchestrated from `lib/app/di/injection_container.dart`.

Registrations are split into modules:

- app-level modules in `lib/app/di/modules/` (core, network, router)
- feature-level modules in `lib/features/<feature>/di/<feature>_module.dart`

Key conventions:

- `injection_container.dart` should only create module list + execute module `register(...)`
- each feature owns its DI graph in its own module file
- keep registration order stable: core -> network -> auth -> features -> router

`AuthBloc` is a lazy singleton and receives `AppStarted` during DI setup.

## Error and result handling

Use `Result<T>` from `app_core` for use case/repository outputs.

- success: `Result.success(data)`
- failure: `Result.failure(Failure)`

Map unexpected errors with `FailureMapper.from(error)`.

UI BLoCs use `ResultBloc.executeResult(...)` to standardize loading/success/failure transitions.

## Logging

Use `LoggerMixin` + `LogContext` in repositories/BLoCs.

Example context tags:

- `AuthRepo`
- `AuthBloc`
- `CampaignRepo`

This keeps logs searchable and consistent across modules.

In development environment, Talker DevTools UI is available at `/devtools/logs`
from the More tab for runtime log inspection.
