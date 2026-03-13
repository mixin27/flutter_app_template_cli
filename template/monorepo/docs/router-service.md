# Routing

The app uses `go_router` with a single `AppRouter` that owns all route
configuration and authentication redirects.

Route paths live in `lib/app/router/app_route_paths.dart`, and the router
implementation lives in `lib/app/router/app_router.dart`.

## Adding a new top-level tab

1. Add a path in `AppRoutePaths`.
2. Add a new `StatefulShellBranch` in `AppRouter`.
3. Add a matching `NavigationDestination` in `AppShell`.

## Passing arguments with `GoRouterState.extra`

When navigating, use `extra` to pass strongly typed objects.

```dart
context.go(
  '${AppRoutePaths.tasks}/$taskId',
  extra: task,
);
```

In the destination route builder:

```dart
final task = state.extra;
if (task is! Task) {
  return const _DetailUnavailablePage(title: 'Task detail unavailable');
}

return TaskDetailPage(task: task);
```

## Notes

- Prefer `AppRoutePaths` constants instead of hard-coded strings.
- Keep route redirects inside `AppRouter` so auth behavior is centralized.
- For simple data, query parameters are fine; use `extra` for objects.
