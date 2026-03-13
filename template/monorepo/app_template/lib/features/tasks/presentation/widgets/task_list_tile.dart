import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    required this.task,
    required this.onToggle,
    required this.onTap,
    this.isUpdating = false,
    super.key,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: isUpdating ? null : (_) => onToggle(),
      ),
      title: Text(
        task.title,
        style: task.isCompleted
            ? theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.onSurfaceVariant,
              )
            : theme.textTheme.bodyLarge,
      ),
      subtitle: task.dueDate == null
          ? null
          : Text('Due ${_formatDate(task.dueDate!)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final month = _monthName(date.month);
    return '$month ${date.day}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
