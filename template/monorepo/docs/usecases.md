# Use Cases (Domain Layer)

This document explains how to implement and use `UseCase` classes in the domain
layer for `__APP_NAME__`.

## Purpose

Use cases are the domain layer entry points. They:

- expose a single action (e.g., `GetCampaigns`, `LoginWithMethod`)
- depend only on domain repositories
- return `Result<T>` so callers handle success/failure explicitly
- avoid any Flutter/UI concerns

## Why use cases are needed

Use cases keep the business logic consistent and testable:

- **Single source of truth**: all application actions flow through a dedicated
  class instead of being spread across UI or repositories.
- **Stable contracts**: `UseCase<T, Params>` makes each operation explicit and
  keeps it easy to discover and reason about.
- **Test isolation**: you can test domain behavior by mocking repositories
  without touching UI or data layers.
- **Dependency control**: presentation only depends on use cases, not on data
  sources or network details.
- **Future-proofing**: use cases are easy to extend with validation, caching
  policies, or orchestration between repositories.

## Contract

The base interface lives in `app_core`:

```dart
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

abstract class SyncUseCase<T, Params> {
  Result<T> call(Params params);
}

abstract class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

abstract class VoidUseCase<Params> implements UseCase<void, Params> {}

abstract class EitherUseCase<L, R, Params> {
  Future<Either<L, R>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

Import `Either` via `app_core` when using `EitherUseCase`.

Use `NoParams` when no input is required.

## Basic patterns

### No parameters

```dart
class GetCampaignsUseCase implements UseCase<List<Campaign>, NoParams> {
  const GetCampaignsUseCase(this._repository);

  final CampaignRepository _repository;

  @override
  Future<Result<List<Campaign>>> call(NoParams params) {
    return _repository.getCampaigns();
  }
}
```

### Stream use case

Use a stream use case when the data is continuous (e.g., live updates or local
cache watchers).

```dart
class WatchCampaignsUseCase
    implements StreamUseCase<List<Campaign>, NoParams> {
  const WatchCampaignsUseCase(this._repository);

  final CampaignRepository _repository;

  @override
  Stream<List<Campaign>> call(NoParams params) {
    return _repository.watchCampaigns();
  }
}
```

### Synchronous use case

Use a sync use case for fast, in-memory operations that do not need `await`.

```dart
class GetCachedCampaignsUseCase
    implements SyncUseCase<List<Campaign>, NoParams> {
  const GetCachedCampaignsUseCase(this._repository);

  final CampaignRepository _repository;

  @override
  Result<List<Campaign>> call(NoParams params) {
    return _repository.getCachedCampaigns();
  }
}
```

### Void use case

Use `VoidUseCase` when the operation has no payload but still reports failure.

```dart
class LogoutUseCase implements VoidUseCase<LogoutParams> {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(LogoutParams params) {
    return _repository.logout(revokeRemote: params.revokeRemote);
  }
}
```

### Either use case

Use `EitherUseCase` when you want to return a non-failure success/error type
pair directly (skipping `Result<T>`).

```dart
class ResolveEntitlementUseCase
    implements EitherUseCase<EntitlementFailure, Entitlement, NoParams> {
  const ResolveEntitlementUseCase(this._repository);

  final EntitlementRepository _repository;

  @override
  Future<Either<EntitlementFailure, Entitlement>> call(NoParams params) {
    return _repository.resolveEntitlement();
  }
}
```

### With parameters

Use a dedicated params class (usually `Equatable`) so you can extend it later.

```dart
class MarkNotificationAsReadUseCase
    implements UseCase<void, MarkNotificationAsReadParams> {
  const MarkNotificationAsReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Result<void>> call(MarkNotificationAsReadParams params) {
    return _repository.markAsRead(params.id);
  }
}

class MarkNotificationAsReadParams extends Equatable {
  const MarkNotificationAsReadParams(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}
```

## Error handling

Use cases return `Result<T>`; they do not throw exceptions. Exceptions are
handled in the data layer and mapped to `Failure` via `FailureMapper`. This
keeps domain logic predictable.

For `void` results, return `Result<void>.success(null)` on success.

## Using a use case in presentation

Plain bloc usage (no `ResultBloc` required):

```dart
final result = await _useCase(const NoParams());
result.fold(
  (failure) => emit(state.copyWith(errorMessage: failure.message)),
  (items) => emit(state.copyWith(items: items)),
);
```

## Registration in DI

Use cases are registered in the feature module:

```dart
getIt.putLazySingletonIfAbsent<GetCampaignsUseCase>(
  () => GetCampaignsUseCase(getIt<CampaignRepository>()),
);
```

## Testing guidance

Use case tests should be thin and verify pass-through:

- given a fake repository, the use case returns the same `Result`
- parameters are forwarded correctly

These tests are fast and keep the domain layer stable.
