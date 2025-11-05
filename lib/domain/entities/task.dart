import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    int? id,
    required String title,
    String? description,
    DateTime? dueDate,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
  }) = _Task;
}
