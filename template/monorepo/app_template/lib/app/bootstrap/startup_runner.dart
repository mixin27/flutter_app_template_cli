import 'dart:async';

import 'startup_logger.dart';
import 'startup_task.dart';

/// Runs startup tasks with consistent logging and timing.
///
/// Why a runner:
/// - Separates startup orchestration from task definition.
/// - Enforces ordering for critical tasks.
/// - Provides a single place to measure duration and handle errors.
class StartupRunner {
  const StartupRunner(this._logger);

  final StartupLogger _logger;

  /// Run tasks marked as critical, in order.
  ///
  /// These block app startup because the UI depends on their results.
  Future<void> runCritical(List<StartupTask> tasks) async {
    for (final task in tasks.where((task) => task.isCritical)) {
      await _runTask(task);
    }
  }

  /// Run non-critical tasks in parallel after the first frame.
  ///
  /// Deferred tasks should be safe to fail without bringing down the app.
  Future<void> runDeferred(List<StartupTask> tasks) async {
    final deferredTasks = tasks.where((task) => !task.isCritical).toList();
    if (deferredTasks.isEmpty) {
      return;
    }

    _logger.info('Running ${deferredTasks.length} deferred startup tasks');

    await Future.wait<void>(
      deferredTasks.map((task) async {
        try {
          await _runTask(task);
        } catch (error, stackTrace) {
          _logger.error(
            'Deferred task failed (${task.name})',
            error,
            stackTrace,
          );
        }
      }),
    );
  }

  /// Execute a single task and log duration.
  Future<void> _runTask(StartupTask task) async {
    final stopwatch = Stopwatch()..start();
    _logger.info('Starting ${task.name}');
    await task.operation();
    stopwatch.stop();
    _logger.info(
      'Completed ${task.name} in ${stopwatch.elapsedMilliseconds}ms',
    );
  }
}
