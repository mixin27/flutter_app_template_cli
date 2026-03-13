import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/router/app_route_paths.dart';
import '../../domain/entities/task.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';
import '../widgets/task_list_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TasksBloc>()..add(const TasksRequested()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state.status == TasksStatus.failure) {
          return _TasksError(message: state.errorMessage);
        }

        if (state.status == TasksStatus.loading && state.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TasksBloc>().add(const TasksRequested());
          },
          child: ListView.separated(
            itemCount: state.tasks.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return TaskListTile(
                task: task,
                isUpdating: state.updatingTaskId == task.id,
                onToggle: () {
                  context
                      .read<TasksBloc>()
                      .add(TaskCompletionToggled(task.id));
                },
                onTap: () => _openTaskDetail(context, task),
              );
            },
          ),
        );
      },
    );
  }

  void _openTaskDetail(BuildContext context, Task task) {
    context.go('${AppRoutePaths.tasks}/${task.id}', extra: task);
  }
}

class _TasksError extends StatelessWidget {
  const _TasksError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? 'Unable to load tasks',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<TasksBloc>().add(const TasksRequested());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
