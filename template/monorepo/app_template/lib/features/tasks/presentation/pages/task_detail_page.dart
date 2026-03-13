import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({required this.task, super.key});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Task detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            _TaskStatusChip(isCompleted: task.isCompleted),
            if (task.dueDate != null) ...[
              const SizedBox(height: 12),
              Text('Due ${_formatDate(task.dueDate!)}'),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(isCompleted ? 'Completed' : 'In progress'),
      backgroundColor: isCompleted
          ? Colors.green.withValues(alpha: 0.15)
          : Colors.orange.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isCompleted ? Colors.green : Colors.orange,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
