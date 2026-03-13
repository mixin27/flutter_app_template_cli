# Bootstrap Walkthrough

This document explains how app startup is structured and why the bootstrap
layer exists. It complements the inline docs under `lib/app/bootstrap/`.

## Why a dedicated bootstrap

We keep startup logic centralized so `main.dart` stays minimal and
startup behavior is consistent across flavors. The bootstrap layer is
responsible for:

- Resolving environment config (`AppConfig.fromEnvironment`).
- Setting up error hooks early (framework + platform errors).
- Registering font licenses before the UI renders.
- Running critical startup tasks before `runApp`.
- Running deferred tasks in the background after the first frame.

## Flow summary

The high-level flow is documented here:

- Diagram: `docs/diagrams/bootstrap_flow.mmd`
- Embed: See the “Bootstrap flow” section in `docs/architecture.md`

## Key components and why they exist

### `bootstrap(...)`

Entry point for startup. It wraps app initialization in `runZonedGuarded`,
builds the startup task list, runs critical tasks, and finally renders the UI.

Why we use it:
- One place to wire all startup concerns.
- Makes the ordering of startup steps explicit.
- Keeps main entry points tiny and consistent.

### `runZonedGuarded`

Why we use it:
- Catches uncaught async errors during startup and after `runApp`.
- Routes fatal errors through a single logger path.
- Preserves stack traces that might otherwise be lost across async boundaries.

### `StartupRunner`

Why we use it:
- Separates orchestration (run critical/deferred) from task definitions.
- Enforces ordering for critical tasks.
- Measures task duration and logs timing consistently.

### `StartupTask`

Why we use it:
- Encapsulates startup operations with a name and critical flag.
- Makes startup work explicit and testable.
- Allows us to reason about what blocks the first frame.

### `StartupLogger`

Why we use it:
- Bootstrap happens before UI logging systems are ready.
- We can enable/disable startup logs via config.
- Adds a clear `[Startup]` prefix to reduce log noise.

### Error hooks

Why we set them early:
- `FlutterError.onError` captures framework exceptions.
- `PlatformDispatcher.onError` captures platform-level async errors.
- Ensures startup failures surface even before the UI is mounted.

## Adding a new startup task

Add it in `lib/app/bootstrap/bootstrap.dart` inside `_buildStartupTasks`:

```dart
StartupTask(
  name: 'sync_remote_config',
  operation: () => syncRemoteConfig(),
  isCritical: false,
),
```

Guidelines:
- **Critical** if the UI cannot function without it.
- **Deferred** if it improves UX but can happen in the background.

## Related files

- `lib/app/bootstrap/bootstrap.dart`
- `lib/app/bootstrap/startup_runner.dart`
- `lib/app/bootstrap/startup_task.dart`
- `lib/app/bootstrap/startup_logger.dart`
