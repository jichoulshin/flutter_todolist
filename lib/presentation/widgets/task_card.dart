import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Checkbox
              InkWell(
                onTap: onToggle,
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                    color: task.isCompleted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16.sp,
                          color: theme.colorScheme.onPrimary,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 12.w),

              // Task Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : null,
                      ),
                    ),
                    if (task.description != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: task.isCompleted
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                )
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (task.dueDate != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14.sp,
                            color: isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            DateTimeUtils.formatDateTime(task.dueDate!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOverdue
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Delete Button
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
