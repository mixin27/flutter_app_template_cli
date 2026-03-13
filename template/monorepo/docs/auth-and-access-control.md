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

Access gating is project-type based, not feature-based.

### Config

- `AUTH_GATE_MODE`
  - `required` -> mandatory login (all non-auth routes require login)
  - `optional` -> optional login (no global redirects)
  - `rewards_only` -> legacy alias for optional login

### How gating works

1. Router receives navigation request.
2. `AuthService` exposes current auth state.
3. `AuthConfig` determines optional vs mandatory login behavior.
4. Mandatory login redirects unauthenticated users to `/login`.
5. Optional login uses `LoginRequiredWrapper` on protected screens (in-place login).

## Auth routes

- `/login`
- `/login/phone`
- `/login/email`
- `/login/otp`

Protected routes can use the `LoginRequiredWrapper` for optional login flows.

## Example policy setups

Optional login (protect specific screens with `LoginRequiredWrapper`):

```bash
--dart-define=AUTH_GATE_MODE=optional
```

Auth required for everything except auth pages:

```bash
--dart-define=AUTH_GATE_MODE=required
```

## Protect a screen in optional login

1. Wrap the screen in `LoginRequiredWrapper` (in `AppRouter` or the page itself).
2. Optionally pass a custom `loginWidget` if the default in-place login is not desired.
3. Add tests for login-required behavior if the route is critical.
