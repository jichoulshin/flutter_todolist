import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart' as entity;

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
sealed class TaskModel with _$TaskModel {
  const factory TaskModel({
    int? id,
    required String title,
    String? description,
    DateTime? dueDate,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  const TaskModel._();

  entity.Task toEntity() {
    return entity.Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }

  factory TaskModel.fromEntity(entity.Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
    );
  }
}
