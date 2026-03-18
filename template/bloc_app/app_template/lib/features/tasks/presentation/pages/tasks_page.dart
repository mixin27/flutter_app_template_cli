import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_title.dart';
import '../bloc/tasks_cubit.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    context.read<TasksCubit>().addTask(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<TasksCubit>().clearError();
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Tasks',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionTitle('Quick Add'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _controller,
                      hintText: 'Add a new task',
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    label: 'Add',
                    icon: Icons.add,
                    onPressed: _submit,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionTitle('Your Tasks'),
              const SizedBox(height: 12),
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, TasksState state) {
    if (state.status == TasksStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.tasks.isEmpty) {
      return const EmptyState(
        title: 'No tasks yet',
        subtitle: 'Create your first task and keep the momentum going.',
      );
    }

    return ListView.separated(
      itemCount: state.tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = state.tasks[index];
        return TaskTile(
          task: task,
          onToggle: (_) => context.read<TasksCubit>().toggleTask(task),
          onDelete: () => context.read<TasksCubit>().deleteTask(task),
        );
      },
    );
  }
}
