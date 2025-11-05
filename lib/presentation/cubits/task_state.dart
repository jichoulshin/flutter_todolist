import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_state.freezed.dart';

@freezed
sealed class TaskState with _$TaskState {
  const factory TaskState.initial() = TaskInitial;

  const factory TaskState.loading() = TaskLoading;

  const factory TaskState.loaded({
    required List<Task> todayTasks,
    required List<Task> upcomingTasks,
    required List<Task> inboxTasks,
    required List<Task> completedTasks,
  }) = TaskLoaded;

  const factory TaskState.error(String message) = TaskError;
}
