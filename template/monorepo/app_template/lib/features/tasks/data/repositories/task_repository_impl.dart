import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl with LoggerMixin implements TaskRepository {
  TaskRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource, {
    AppLogger? logger,
  }) : _logger = logger ?? AppLogger(enabled: false);

  final TaskLocalDataSource _localDataSource;
  final TaskRemoteDataSource _remoteDataSource;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('TaskRepo');

  @override
  Future<Result<List<Task>>> getTasks() async {
    try {
      final cached = await _localDataSource.getTasks();
      if (cached.isNotEmpty) {
        log.debug('Loaded ${cached.length} tasks from cache');
      }

      try {
        log.debug('Syncing tasks from remote source');
        final remote = await _remoteDataSource.getTasks();
        await _localDataSource.saveTasks(remote);
        return Result.success(remote);
      } catch (error) {
        if (cached.isNotEmpty) {
          log.warning('Remote sync failed, using cached tasks');
          return Result.success(cached);
        }

        log.error('Failed to load tasks', error: error);
        return Result.failure(FailureMapper.from(error));
      }
    } catch (error) {
      log.error('Task cache read failed', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }

  @override
  Future<Result<Task>> toggleTask(String taskId) async {
    try {
      final updated = await _localDataSource.toggleTask(taskId);
      try {
        await _remoteDataSource.updateTaskStatus(taskId, updated.isCompleted);
      } catch (error) {
        log.warning('Failed to sync task update: $error');
      }

      return Result.success(updated);
    } catch (error) {
      log.error('Failed to toggle task', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }
}
