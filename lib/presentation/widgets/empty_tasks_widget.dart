import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyTasksWidget extends StatelessWidget {
  final String message;

  const EmptyTasksWidget({super.key, this.message = 'No tasks yet'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80.sp,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
