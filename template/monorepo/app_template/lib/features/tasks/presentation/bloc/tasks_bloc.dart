import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_use_case.dart';
import '../../domain/usecases/toggle_task_use_case.dart';
import 'tasks_event.dart';
import 'tasks_state.dart';

class TasksBloc extends ResultBloc<TasksEvent, TasksState> with LoggerMixin {
  TasksBloc(this._getTasksUseCase, this._toggleTaskUseCase, {AppLogger? logger})
    : _logger = logger ?? AppLogger(enabled: false),
      super(const TasksState()) {
    on<TasksRequested>(_onTasksRequested);
    on<TaskCompletionToggled>(_onTaskCompletionToggled);
  }

  final GetTasksUseCase _getTasksUseCase;
  final ToggleTaskUseCase _toggleTaskUseCase;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('TasksBloc');

  Future<void> _onTasksRequested(
    TasksRequested event,
    Emitter<TasksState> emit,
  ) async {
    log.info('Tasks requested');
    await executeResult(
      emit: emit,
      loadingState: state.copyWith(status: TasksStatus.loading),
      request: () => _getTasksUseCase(const NoParams()),
      onFailure: (failure) {
        log.warning('Failed to load tasks: ${failure.message}');
        return state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
        );
      },
      onSuccess: (tasks) {
        log.info('Loaded ${tasks.length} tasks');
        return state.copyWith(status: TasksStatus.success, tasks: tasks);
      },
    );
  }

  Future<void> _onTaskCompletionToggled(
    TaskCompletionToggled event,
    Emitter<TasksState> emit,
  ) async {
    log.info('Toggle task ${event.taskId}');
    emit(
      state.copyWith(
        status: TasksStatus.updating,
        updatingTaskId: event.taskId,
      ),
    );

    final result = await _toggleTaskUseCase(ToggleTaskParams(event.taskId));
    emitResult(
      result,
      emit,
      onFailure: (failure) {
        log.warning('Failed to toggle task: ${failure.message}');
        return state.copyWith(
          status: TasksStatus.failure,
          errorMessage: failure.message,
          updatingTaskId: null,
        );
      },
      onSuccess: (task) {
        final updatedTasks = _mergeTask(state.tasks, task);
        return state.copyWith(
          status: TasksStatus.success,
          tasks: updatedTasks,
          updatingTaskId: null,
        );
      },
    );
  }

  List<Task> _mergeTask(List<Task> tasks, Task updated) {
    return tasks
        .map((task) => task.id == updated.id ? updated : task)
        .toList(growable: false);
  }
}
