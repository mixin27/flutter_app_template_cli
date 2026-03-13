# Feature Development Playbook

This guide is for implementing features consistently, including junior-friendly steps.

## 1) Start with a feature contract

Before coding, write down:

- user story
- API endpoints needed
- local persistence needed (if any)
- access control requirement (guest vs auth-required)
- acceptance criteria

## 2) Create feature folders

```text
lib/features/<feature>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc/
    pages/
    widgets/
```

## 3) Domain first

- Define entity classes (`equatable`).
- Define repository contract.
- Define use case classes.

Use `Result<T>` for outputs.

## 4) Data layer

- Create remote datasource (via `APIService`).
- Create local datasource (Drift or token/storage abstraction as needed).
- Implement repository and map errors with `FailureMapper.from(error)`.
- Add scoped logging with `LoggerMixin` + `LogContext`.

## 5) Presentation layer

- Create event/state classes (`equatable`).
- Create bloc extending `ResultBloc`.
- Use `executeResult(...)` for loading/failure/success.
- Keep widgets dumb when possible; delegate behavior to bloc.

## 6) Wire dependency injection

Create feature DI module:

- `lib/features/<feature>/di/<feature>_module.dart`
  - datasource registrations
  - repository registration
  - use case registrations
  - bloc registration
- import module in `lib/app/di/injection_container.dart`
- add `const <Feature>Module()` to module list in `configureDependencies(...)`

## 7) Routing and access control

If new pages are needed:

- add route path constant to `RouterPath`
- add route in `AppRouter`

If feature needs auth in optional login mode:

- wrap the page with `LoginRequiredWrapper`
- optionally provide a custom `loginWidget` or deep-link `from` parameter

## 8) Tests to add (minimum)

- repository success/failure tests
- use case pass-through tests
- bloc transition tests for key events
- strategy/guard tests if route auth behavior changed

## 9) Definition of done

- `flutter analyze` passes
- `flutter test` passes
- docs updated when behavior/config changes
- feature reviewed by another dev

## 10) Junior pairing checklist

- Implement domain contracts together.
- Junior writes data implementation + tests.
- Review error mapping and log messages together.
- Junior wires presentation + bloc.
- Senior reviews DI/router/access control changes.
