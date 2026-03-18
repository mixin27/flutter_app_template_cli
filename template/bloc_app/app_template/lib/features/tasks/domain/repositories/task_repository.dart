import '../../../../core/result/result.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();

  Future<Result<void>> addTask(String title);

  Future<Result<void>> toggleTask(Task task);

  Future<Result<void>> deleteTask(Task task);
}
