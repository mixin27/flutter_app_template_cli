import 'package:equatable/equatable.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;

  @override
  List<Object?> get props => [id, title, isCompleted, dueDate];

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
