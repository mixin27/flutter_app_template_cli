import 'package:equatable/equatable.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

final class TasksRequested extends TasksEvent {
  const TasksRequested();
}

final class TaskCompletionToggled extends TasksEvent {
  const TaskCompletionToggled(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}
