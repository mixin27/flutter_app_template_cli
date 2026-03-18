# __APP_NAME__

BLoC + clean architecture starter with a feature-first layout, GoRouter navigation, and offline-first profile sync using Drift.

## Highlights

- Feature-first structure with `data`, `domain`, and `presentation` layers.
- BLoC for state management.
- GetIt modules for DI (`core`, `auth`, `profile`, `tasks`).
- GoRouter with auth-aware redirects and a bottom navigation shell.
- Offline-first profile sync with cached fallback.
- Drift database with sample `tasks`, `auth`, and `profile` tables.
- Core utilities: config, base result types, extensions, and reusable widgets.

## Project Structure

```
lib/
  app/
    router/
    shell/
  core/
  data/
  di/
  features/
```

## Configuration

`AppConfig` reads environment values via `--dart-define`:

- `APP_NAME`
- `ENV`
- `API_BASE_URL`
- `ENABLE_LOGGING`
- `USE_MOCK_API` (default: true)

Example:

```
flutter run \
  --dart-define=APP_NAME=__APP_NAME__ \
  --dart-define=ENV=dev \
  --dart-define=API_BASE_URL=https://example.com/api \
  --dart-define=ENABLE_LOGGING=true \
  --dart-define=USE_MOCK_API=true
```

## Drift Codegen

Regenerate Drift files when you change tables:

```
dart run build_runner build --delete-conflicting-outputs
```

## Testing

```
flutter test
```
