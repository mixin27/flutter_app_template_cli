# Auth and Access Control

## Goal

Authentication is flexible by configuration.

- Users can browse as guest when policy allows.
- Optional login can show in-place login for protected screens.
- The project supports multiple auth methods (phone OTP, email/password, extensible social/custom).

## Auth module overview

### Core pieces

- `AuthRepository` (domain contract)
- `AuthRepositoryImpl` (data implementation)
- `AuthRemoteDataSource` and `AuthLocalDataSource`
- `AuthBloc` (global app-scoped)

### Supported auth flows

- Phone OTP request + verify
  - purpose: `login` or `registration`
- Email/password login
- Method login (`google`, `apple`, `facebook`, `custom`)
- Refresh token flow (interceptor-driven)
- Logout (remote revoke + local clear)

### Current remote endpoint paths

- `POST /auth/otp/request`
- `POST /auth/otp/verify`
- `POST /auth/login`
- `POST /auth/logout`
- `POST /auth/refresh`

If backend paths differ, update `AuthRemoteDataSourceImpl`.

## Global auth state (`AuthBloc`)

Main lifecycle events:

- `AppStarted`
- `LoggedIn`
- `LoggedOut`
- `SessionExpired`

Other auth action events:

- `PhoneOtpRequested`
- `PhoneOtpVerified`
- `EmailPasswordLoginRequested`
- `MethodLoginRequested`

`SessionExpired` is dispatched from network layer callback when refresh fails.

## Auth configuration

Access gating is controlled by `AuthGateMode` and an `AuthAccessStrategy`.
The default mode is feature-scoped so you can require login only for certain
routes/features.

### Config

- `AUTH_GATE_MODE`
  - `required` -> mandatory login (all non-auth routes require login)
  - `optional` -> optional login (no global redirects)
  - `feature_scoped` -> require login only for specific features/routes
- `AUTH_REQUIRED_FEATURES`
  - comma-separated list of feature IDs (defaults to `tasks,profile`)

### How gating works

1. Router receives a navigation request.
2. `AuthBloc` exposes current session state.
3. `AuthAccessStrategy` (from `AuthGateMode`) decides if the path requires auth.
4. If auth is required and the user is a guest, redirect to `/login?from=...`.
5. Otherwise the route is allowed.

Feature-scoped mode uses `AuthFeatureRegistry` to map routes to feature IDs,
then checks them against `AUTH_REQUIRED_FEATURES`.

## Auth routes

- `/login`
- `/login/phone`
- `/login/email`
- `/login/otp`

## Example policy setups

Optional login (no global redirects):

```bash
--dart-define=AUTH_GATE_MODE=optional
```

Feature-scoped login (require auth for specific features):

```bash
--dart-define=AUTH_GATE_MODE=feature_scoped
--dart-define=AUTH_REQUIRED_FEATURES=tasks,profile
```

Auth required for everything except auth pages:

```bash
--dart-define=AUTH_GATE_MODE=required
```

## Protect a feature in feature-scoped mode

1. Add a rule to `AuthFeatureRegistry` for the feature’s route prefix.
2. Add the feature ID to `AUTH_REQUIRED_FEATURES` (or update the default list in `AppConfig`).
3. Add tests for login-required behavior if the route is critical.
