import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/task.dart';
import 'task_card.dart';

class TaskListSection extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(int) onToggle;
  final Function(int) onDelete;

  const TaskListSection({
    super.key,
    required this.title,
    required this.tasks,
    required this.onTaskTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tasks.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        ...tasks.map(
          (task) => TaskCard(
            task: task,
            onTap: () => onTaskTap(task),
            onToggle: task.id != null ? () => onToggle(task.id!) : null,
            onDelete: task.id != null ? () => onDelete(task.id!) : null,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
