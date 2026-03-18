import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleTask extends UseCase<void, ToggleTaskParams> {
  ToggleTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<void>> call(ToggleTaskParams params) {
    return _repository.toggleTask(params.task);
  }
}

class ToggleTaskParams {
  const ToggleTaskParams({required this.task});

  final Task task;
}
