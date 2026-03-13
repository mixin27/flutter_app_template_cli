/// Function signature for a startup operation.
///
/// Startup tasks are async by default to allow IO and initialization work.
typedef StartupOperation = Future<void> Function();

/// Describes a single unit of startup work.
///
/// Why tasks:
/// - Makes startup steps explicit and testable.
/// - Allows the runner to separate critical vs. deferred work.
/// - Enables consistent logging/metrics for each task.
class StartupTask {
  const StartupTask({
    required this.name,
    required this.operation,
    this.isCritical = true,
  });

  /// Human-readable task name for logs and diagnostics.
  final String name;

  /// Operation executed by the [StartupRunner].
  final StartupOperation operation;

  /// Whether the task must complete before rendering the app.
  final bool isCritical;
}
