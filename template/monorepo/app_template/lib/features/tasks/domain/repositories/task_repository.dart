import 'package:app_core/app_core.dart';

import '../entities/task.dart';

abstract class TaskRepository {
  Future<Result<List<Task>>> getTasks();

  Future<Result<Task>> toggleTask(String taskId);
}
