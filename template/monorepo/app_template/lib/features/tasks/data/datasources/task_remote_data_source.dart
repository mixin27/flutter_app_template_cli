import 'package:app_network/app_network.dart';

import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();

  Future<void> updateTaskStatus(String taskId, bool isCompleted);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TaskModel>> getTasks() async {
    final payload = await _apiClient.getList('/tasks');
    return payload.map(TaskModel.fromJson).toList(growable: false);
  }

  @override
  Future<void> updateTaskStatus(String taskId, bool isCompleted) async {
    await _apiClient.patch(
      '/tasks/$taskId',
      data: {'isCompleted': isCompleted},
    );
  }
}
