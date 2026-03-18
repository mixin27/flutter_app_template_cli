import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class DeleteTask extends UseCase<void, DeleteTaskParams> {
  DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<void>> call(DeleteTaskParams params) {
    return _repository.deleteTask(params.task);
  }
}

class DeleteTaskParams {
  const DeleteTaskParams({required this.task});

  final Task task;
}
