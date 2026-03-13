import 'package:app_core/app_core.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase extends UseCase<List<Task>, NoParams> {
  GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<List<Task>>> call(NoParams params) {
    return _repository.getTasks();
  }
}
