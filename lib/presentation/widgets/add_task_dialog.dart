import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/task.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // 날짜를 선택하면 자동으로 00:00으로 설정
        _selectedTime ??= const TimeOfDay(hour: 0, minute: 0);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime? _getCombinedDateTime() {
    if (_selectedDate == null) return null;
    if (_selectedTime == null) return _selectedDate;

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: _getCombinedDateTime(),
        createdAt: DateTime.now(),
      );
      Navigator.of(context).pop(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Add New Task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.r),

                // Subtitle
                Text(
                  'Set due date and time for your task',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 24.r),

                // Task Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'Enter task title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),

                SizedBox(height: 16.r),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter task description',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),

                SizedBox(height: 16.r),

                // Date & Time Pickers
                Text(
                  'Due Date & Time',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.r),
                Row(
                  children: [
                    // Date Picker
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? 'Due Date'
                              : DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDate!),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.r),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.r),

                    // Time Picker
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _selectedTime == null
                              ? 'Due Time'
                              : _selectedTime!.format(context),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.r),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_selectedDate != null || _selectedTime != null) ...[
                  SizedBox(height: 8.r),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _selectedTime = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Date & Time'),
                  ),
                ],

                SizedBox(height: 24.r),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.r),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.r,
                          vertical: 12.r,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
