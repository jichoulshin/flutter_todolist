import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/task.dart';
import '../cubits/task_cubit.dart';
import '../cubits/task_state.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isEditing = false;
  Task? _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _titleController = TextEditingController(text: _currentTask!.title);
    _descriptionController = TextEditingController(
      text: _currentTask!.description ?? '',
    );
    if (_currentTask!.dueDate != null) {
      _selectedDate = _currentTask!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(_currentTask!.dueDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TaskCubit, TaskState>(
      listener: (context, state) {
        // Update current task when state changes
        state.whenOrNull(
          loaded: (todayTasks, upcomingTasks, inboxTasks, completedTasks) {
            final allTasks = [
              ...todayTasks,
              ...upcomingTasks,
              ...inboxTasks,
              ...completedTasks,
            ];
            final updatedTask = allTasks.firstWhere(
              (t) => t.id == widget.task.id,
              orElse: () => _currentTask!,
            );
            if (updatedTask.id == _currentTask!.id) {
              setState(() {
                _currentTask = updatedTask;
                if (!_isEditing) {
                  _titleController.text = _currentTask!.title;
                  _descriptionController.text = _currentTask!.description ?? '';
                  if (_currentTask!.dueDate != null) {
                    _selectedDate = _currentTask!.dueDate;
                    _selectedTime = TimeOfDay.fromDateTime(
                      _currentTask!.dueDate!,
                    );
                  } else {
                    _selectedDate = null;
                    _selectedTime = null;
                  }
                }
              });
            }
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'task.edit'.tr() : 'task.details'.tr()),
          actions: [
            if (!_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteDialog(context);
                },
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _titleController.text = _currentTask!.title;
                    _descriptionController.text =
                        _currentTask!.description ?? '';
                    if (_currentTask!.dueDate != null) {
                      _selectedDate = _currentTask!.dueDate;
                      _selectedTime = TimeOfDay.fromDateTime(
                        _currentTask!.dueDate!,
                      );
                    }
                  });
                },
                child: Text('task.cancel'.tr()),
              ),
              TextButton(onPressed: _saveTask, child: Text('task.save'.tr())),
            ],
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _currentTask!.isCompleted
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentTask!.isCompleted
                          ? 'task.mark_incomplete'.tr()
                          : 'task.mark_complete'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _currentTask!.isCompleted
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Switch(
                      value: _currentTask!.isCompleted,
                      onChanged: _currentTask!.id != null && !_isEditing
                          ? (value) {
                              context.read<TaskCubit>().toggleTaskCompletion(
                                _currentTask!.id!,
                              );
                              context.pop();
                            }
                          : null,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                'task.title'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 8.h),
              if (_isEditing)
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'task.title_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  style: theme.textTheme.headlineMedium,
                )
              else
                Text(
                  _currentTask!.title,
                  style: theme.textTheme.headlineMedium,
                ),

              SizedBox(height: 24.h),

              // Description
              Text(
                'task.description'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 8.h),
              if (_isEditing)
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'task.description_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 5,
                  style: theme.textTheme.bodyLarge,
                )
              else if (_currentTask!.description != null &&
                  _currentTask!.description!.isNotEmpty)
                Text(
                  _currentTask!.description!,
                  style: theme.textTheme.bodyLarge,
                )
              else
                Text(
                  'task.no_description'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),

              SizedBox(height: 24.h),

              // Due Date & Time
              Text(
                'task.due_date_time'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 8.h),
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'task.select_date'.tr(),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.r,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.r),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectedDate != null
                            ? () => _selectTime(context)
                            : null,
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'task.select_time'.tr(),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.r,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedDate != null) ...[
                  SizedBox(height: 8.h),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _selectedTime = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: Text('task.clear_date'.tr()),
                  ),
                ],
              ] else ...[
                if (_currentTask!.dueDate != null)
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 12.r),
                        Text(
                          DateTimeUtils.formatDateTime(_currentTask!.dueDate!),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'task.no_due_date'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],

              SizedBox(height: 24.h),

              // Created At
              Text(
                'task.created_at'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                DateTimeUtils.formatDateTime(_currentTask!.createdAt),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ), // SingleChildScrollView 끝
      ), // Scaffold body 끝
    ); // BlocListener child (Scaffold) 끝
  } // build 메서드 끝

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime ??= const TimeOfDay(hour: 0, minute: 0);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 0, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('task.title_required'.tr())));
      return;
    }

    DateTime? dueDate;
    if (_selectedDate != null && _selectedTime != null) {
      dueDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: dueDate,
      isCompleted: widget.task.isCompleted,
      createdAt: widget.task.createdAt,
    );

    context.read<TaskCubit>().updateTask(updatedTask);

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('task.updated'.tr())));
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('task.delete'.tr()),
        content: Text('task.delete_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('task.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (widget.task.id != null) {
                context.read<TaskCubit>().deleteTask(widget.task.id!);
              }
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: Text(
              'task.delete'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
