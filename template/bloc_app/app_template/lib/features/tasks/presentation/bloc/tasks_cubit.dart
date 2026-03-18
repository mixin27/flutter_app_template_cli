import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_task.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(TaskRepository repository)
    : _repository = repository,
      _addTask = AddTask(repository),
      _toggleTask = ToggleTask(repository),
      _deleteTask = DeleteTask(repository),
      super(const TasksState());

  final TaskRepository _repository;
  final AddTask _addTask;
  final ToggleTask _toggleTask;
  final DeleteTask _deleteTask;

  StreamSubscription<List<Task>>? _subscription;

  void initialize() {
    emit(state.copyWith(status: TasksStatus.loading));
    _subscription?.cancel();
    _subscription = _repository.watchTasks().listen(
      (tasks) {
        emit(
          state.copyWith(
            status: TasksStatus.ready,
            tasks: tasks,
            errorMessage: null,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: TasksStatus.failure,
            errorMessage: 'Failed to load tasks: $error',
          ),
        );
      },
    );
  }

  Future<void> addTask(String title) async {
    final result = await _addTask(AddTaskParams(title: title));
    _handleResult(result);
  }

  Future<void> toggleTask(Task task) async {
    final result = await _toggleTask(ToggleTaskParams(task: task));
    _handleResult(result);
  }

  Future<void> deleteTask(Task task) async {
    final result = await _deleteTask(DeleteTaskParams(task: task));
    _handleResult(result);
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null, status: TasksStatus.ready));
    }
  }

  void _handleResult(Result<void> result) {
    result.when(success: (_) {}, failure: (failure) => _emitFailure(failure));
  }

  void _emitFailure(Failure failure) {
    emit(
      state.copyWith(
        status: TasksStatus.failure,
        errorMessage: failure.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
