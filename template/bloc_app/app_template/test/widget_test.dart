import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:__APP_NAME__/core/result/result.dart';
import 'package:__APP_NAME__/features/tasks/domain/entities/task.dart';
import 'package:__APP_NAME__/features/tasks/domain/repositories/task_repository.dart';
import 'package:__APP_NAME__/features/tasks/presentation/bloc/tasks_cubit.dart';
import 'package:__APP_NAME__/features/tasks/presentation/pages/tasks_page.dart';

void main() {
  testWidgets('Shows empty state when no tasks', (tester) async {
    final repository = FakeTaskRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => TasksCubit(repository)..initialize(),
          child: const TasksPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No tasks yet'), findsOneWidget);
  });
}

class FakeTaskRepository implements TaskRepository {
  @override
  Stream<List<Task>> watchTasks() => Stream.value(const []);

  @override
  Future<Result<void>> addTask(String title) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> toggleTask(Task task) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteTask(Task task) async {
    return Result.success(null);
  }
}
