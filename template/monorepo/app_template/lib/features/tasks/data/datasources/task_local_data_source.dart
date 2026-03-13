import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();

  Future<void> saveTasks(List<TaskModel> tasks);

  Future<TaskModel> toggleTask(String taskId);

  Future<void> seedSampleDataIfEmpty();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final List<TaskModel> _cache = [];

  @override
  Future<List<TaskModel>> getTasks() async {
    return List.unmodifiable(_cache);
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    _cache
      ..clear()
      ..addAll(tasks);
  }

  @override
  Future<TaskModel> toggleTask(String taskId) async {
    final index = _cache.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      throw StateError('Task not found: $taskId');
    }

    final updated = _cache[index].copyWith(
      isCompleted: !_cache[index].isCompleted,
    );
    _cache[index] = TaskModel.fromEntity(updated);
    return _cache[index];
  }

  @override
  Future<void> seedSampleDataIfEmpty() async {
    if (_cache.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    _cache.addAll([
      TaskModel(
        id: 'task-001',
        title: 'Review today\'s priorities',
        isCompleted: false,
        dueDate: now.add(const Duration(hours: 2)),
      ),
      TaskModel(
        id: 'task-002',
        title: 'Draft product update email',
        isCompleted: true,
        dueDate: now,
      ),
      TaskModel(
        id: 'task-003',
        title: 'Sync with design on new flow',
        isCompleted: false,
        dueDate: now.add(const Duration(days: 1)),
      ),
    ]);
  }
}
