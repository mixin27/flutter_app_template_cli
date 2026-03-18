import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/result/result.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._dao);

  final TasksDao _dao;

  @override
  Stream<List<Task>> watchTasks() {
    return _dao.watchAllTasks().map(
      (records) => records
          .map((record) => TaskModel.fromRecord(record).toEntity())
          .toList(),
    );
  }

  @override
  Future<Result<void>> addTask(String title) async {
    if (title.isBlank) {
      return Result.failure(
        const ValidationFailure(message: 'Task title cannot be empty.'),
      );
    }

    try {
      await _dao.createTask(title: title.trim());
      return Result.success(null);
    } catch (error) {
      return Result.failure(
        DatabaseFailure(message: 'Unable to create task: $error'),
      );
    }
  }

  @override
  Future<Result<void>> toggleTask(Task task) async {
    try {
      await _dao.updateTaskStatus(id: task.id, isDone: !task.isDone);
      return Result.success(null);
    } catch (error) {
      return Result.failure(
        DatabaseFailure(message: 'Unable to update task: $error'),
      );
    }
  }

  @override
  Future<Result<void>> deleteTask(Task task) async {
    try {
      await _dao.deleteTask(task.id);
      return Result.success(null);
    } catch (error) {
      return Result.failure(
        DatabaseFailure(message: 'Unable to delete task: $error'),
      );
    }
  }
}
