# Testing and Release Checklist

## Test strategy

### Unit tests

Focus on:

- repository behavior (success/failure/fallback)
- use case behavior and parameter pass-through
- bloc state transitions
- auth guard decisions (optional vs required login)

### Integration-focused checks

- router redirects for protected routes
- auth flows (phone OTP, email/password)
- session expiration behavior

## Standard quality commands

Run from project root:

```bash
flutter pub get
flutter analyze
flutter test
```

Additional package checks:

```bash
flutter test packages/app_network
flutter analyze packages/app_network/lib packages/app_network/test
```

## Pre-PR checklist

- [ ] No analyzer issues.
- [ ] All tests passing locally.
- [ ] New logic has tests.
- [ ] DI changes validated by running app.
- [ ] Router changes validated on at least one simulator/emulator.
- [ ] Documentation updated for new config flags/routes/features.

## Pre-release checklist

- [ ] Correct entrypoint selected (`main_development`, `main_staging`, or `main_production`).
- [ ] Correct `API_BASE_URL` and `APP_ENV`.
- [ ] Correct auth gate setting (`AUTH_GATE_MODE`).
- [ ] Correct flavor Firebase files available (`apps/<app>/android/firebase/<flavor>/...`, `apps/<app>/ios/firebase/<flavor>/...`).
- [ ] `make prepare-firebase FLAVOR=<flavor>` executed before release build.
- [ ] Android release signing configured (`apps/<app>/android/key.properties` + keystore).
- [ ] iOS signing assets available for signed IPA pipeline (`p12` + provisioning profile).
- [ ] Sample seed disabled for production.
- [ ] Verbose startup logs disabled for production.

## Quick troubleshooting

### iOS pod issues

```bash
cd apps/<app>/ios
pod install
cd ..
flutter clean
flutter pub get
```

### Stale generated/build artifacts

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Unexpected guest/redirect behavior

Check:

- `AUTH_GATE_MODE`
- `AuthConfig` (optional vs mandatory)
- `LoginRequiredWrapper` usage on protected routes
- current `AuthBloc` state
