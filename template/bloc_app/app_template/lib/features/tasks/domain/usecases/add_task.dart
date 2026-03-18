import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/task_repository.dart';

class AddTask extends UseCase<void, AddTaskParams> {
  AddTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<void>> call(AddTaskParams params) {
    return _repository.addTask(params.title);
  }
}

class AddTaskParams {
  const AddTaskParams({required this.title});

  final String title;
}
