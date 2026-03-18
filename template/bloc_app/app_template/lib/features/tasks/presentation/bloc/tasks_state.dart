part of 'tasks_cubit.dart';

enum TasksStatus { initial, loading, ready, failure }

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage,
  });

  final TasksStatus status;
  final List<Task> tasks;
  final String? errorMessage;

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, errorMessage];
}
