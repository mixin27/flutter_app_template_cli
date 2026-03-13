import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';

enum TasksStatus { initial, loading, success, failure, updating }

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage,
    this.updatingTaskId,
  });

  final TasksStatus status;
  final List<Task> tasks;
  final String? errorMessage;
  final String? updatingTaskId;

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    String? errorMessage,
    String? updatingTaskId,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
      updatingTaskId: updatingTaskId,
    );
  }

  @override
  List<Object?> get props => [status, tasks, errorMessage, updatingTaskId];
}
