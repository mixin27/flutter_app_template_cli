import '../../../../data/database/app_database.dart';
import '../../domain/entities/task.dart';

class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  final int id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  factory TaskModel.fromRecord(TaskRecord record) {
    return TaskModel(
      id: record.id,
      title: record.title,
      isDone: record.isDone,
      createdAt: record.createdAt,
    );
  }

  Task toEntity() {
    return Task(id: id, title: title, isDone: isDone, createdAt: createdAt);
  }
}
