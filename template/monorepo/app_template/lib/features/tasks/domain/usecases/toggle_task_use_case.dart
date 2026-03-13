import 'package:app_core/app_core.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTaskParams {
  const ToggleTaskParams(this.taskId);

  final String taskId;
}

class ToggleTaskUseCase extends UseCase<Task, ToggleTaskParams> {
  ToggleTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<Task>> call(ToggleTaskParams params) {
    return _repository.toggleTask(params.taskId);
  }
}
