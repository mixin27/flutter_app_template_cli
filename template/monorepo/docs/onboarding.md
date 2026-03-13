# Onboarding Guide

## 1) Prerequisites

- Flutter SDK compatible with this project (`sdk: ^3.11.0` in `pubspec.yaml`).
- Xcode + CocoaPods for iOS development.
- Android Studio + Android SDK for Android development.
- Git and a terminal.

## 2) Clone and install

From project root:

```bash
make setup-dev
```

This runs first-time contributor setup:

- workspace dependency resolution
- git hooks installation
- `.env` initialization (if missing)
- workspace code generation

Alternative (manual steps):

```bash
flutter pub get
make install-hooks
make env-init ENV=development
make codegen
```

## 3) Run the app

Default entrypoint:

```bash
flutter run
```

Flavor entrypoints:

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor production -t lib/main_production.dart
```

VS Code launch profiles are also prepared in `.vscode/launch.json`:

- `__APP_NAME__: Main (Auto Env)`
- `__APP_NAME__: Development`
- `__APP_NAME__: Development (Guest Mode)`
- `__APP_NAME__: Development (Auth Required)`
- `__APP_NAME__: Staging`
- `__APP_NAME__: Production`

Native flavor mapping:

- Android flavors: `development`, `staging`, `production`
- iOS schemes: `development`, `staging`, `production`

## 3.1) Bootstrap overview

Before the UI renders, the app runs through a bootstrap sequence that wires
dependencies, sets error hooks, and runs startup tasks. The walkthrough is
documented here:

- `docs/bootstrap.md`

## 4) Environment and runtime flags

Useful `--dart-define` values:

- `APP_ENV=development|staging|production`
- `API_BASE_URL=https://your-api.example.com/v1`
- `ENABLE_SAMPLE_SEED_DATA=true|false`
- `ENABLE_VERBOSE_STARTUP_LOGS=true|false`
- `AUTH_GATE_MODE=optional|required` (or legacy `rewards_only` alias)

Example:

```bash
flutter run \
  -t lib/main_development.dart \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=https://dev-api.example.com/v1 \
  --dart-define=AUTH_GATE_MODE=optional
```

Optional `.env` setup (Envied):

```bash
make env-init ENV=development
make codegen
```

Resolution order for config values is:

1. `--dart-define`
2. `.env`
3. built-in defaults

## 5) Common development commands

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

Workspace script shortcuts:

```bash
make pub-get
make analyze
make test
make check
make install-hooks
make setup-dev
make codegen
make secret-scan
make deps-outdated
make prepare-firebase FLAVOR=development
```

Package-level commands (examples):

```bash
flutter test packages/app_network
flutter analyze packages/app_network/lib packages/app_network/test
```

## 6) iOS notes

If iOS dependency errors appear:

```bash
cd apps/<app>/ios
pod install
cd ..
```

Then rerun `flutter run`.

## 7) Firebase flavor files (optional)

If your run needs Firebase services, add per-flavor files under the app root:

- `apps/<app>/android/firebase/<flavor>/google-services.json`
- `apps/<app>/ios/firebase/<flavor>/GoogleService-Info.plist`

Then prepare Android's flavor file location:

```bash
make prepare-firebase FLAVOR=development
```

## 8) Development log devtools

When running in development environment (`APP_ENV=development`), open:

- More tab -> `Open Log DevTools`

This launches Talker log console for runtime log inspection.

## 9) Day-1 checklist for new team members

- Run app on one simulator/emulator.
- Run `make install-hooks` to enable husky hooks (pre-push + commit-msg).
- Install `gitleaks` locally to enable staged secret scan in pre-push hook.
- Run `make secret-scan` once and ensure no secret findings.
- Run `flutter analyze` and ensure zero issues.
- Run `flutter test` and ensure all tests pass.
- Read `docs/architecture.md` and `docs/auth-and-access-control.md`.
- Pair with a senior dev before modifying DI module wiring (`injection_container.dart`, `app/di/modules/`) or `app_router.dart`.
