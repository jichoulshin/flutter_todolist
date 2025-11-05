import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_completed_tasks_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_completion_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../services/notification_service.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase _getTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final DeleteCompletedTasksUseCase _deleteCompletedTasksUseCase;
  final ToggleTaskCompletionUseCase _toggleTaskCompletionUseCase;
  final NotificationService _notificationService;

  TaskCubit({
    required GetTasksUseCase getTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required DeleteCompletedTasksUseCase deleteCompletedTasksUseCase,
    required ToggleTaskCompletionUseCase toggleTaskCompletionUseCase,
    required NotificationService notificationService,
  }) : _getTasksUseCase = getTasksUseCase,
       _addTaskUseCase = addTaskUseCase,
       _updateTaskUseCase = updateTaskUseCase,
       _deleteTaskUseCase = deleteTaskUseCase,
       _deleteCompletedTasksUseCase = deleteCompletedTasksUseCase,
       _toggleTaskCompletionUseCase = toggleTaskCompletionUseCase,
       _notificationService = notificationService,
       super(const TaskState.initial());

  Future<void> loadTasks() async {
    try {
      emit(const TaskState.loading());

      final todayTasks = await _getTasksUseCase.getTodayTasks();
      final upcomingTasks = await _getTasksUseCase.getUpcomingTasks();
      final allTasks = await _getTasksUseCase.getAllTasks();
      final completedTasks = await _getTasksUseCase.getCompletedTasks();

      // Inbox: tasks without due date
      final inboxTasks = allTasks
          .where((t) => t.dueDate == null && !t.isCompleted)
          .toList();

      emit(
        TaskState.loaded(
          todayTasks: todayTasks,
          upcomingTasks: upcomingTasks,
          inboxTasks: inboxTasks,
          completedTasks: completedTasks,
        ),
      );
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> addTask(Task task) async {
    try {
      // addTask는 새로 생성된 task의 id를 반환함
      final newTaskId = await _addTaskUseCase(task);

      // 새로 생성된 task에 id를 추가해서 알림 예약
      if (task.dueDate != null) {
        final taskWithId = Task(
          id: newTaskId,
          title: task.title,
          description: task.description,
          dueDate: task.dueDate,
          isCompleted: task.isCompleted,
          createdAt: task.createdAt,
        );
        await _notificationService.scheduleTaskReminder(taskWithId);
      }

      await loadTasks();
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _updateTaskUseCase(task);

      // Cancel old notification and schedule new one if task has due date
      if (task.id != null) {
        await _notificationService.cancelTaskReminder(task.id!);
        if (task.dueDate != null) {
          await _notificationService.scheduleTaskReminder(task);
        }
      }

      await loadTasks();
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      // Cancel notification when deleting task
      await _notificationService.cancelTaskReminder(id);
      await _deleteTaskUseCase(id);
      await loadTasks();
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> toggleTaskCompletion(int id) async {
    try {
      await _toggleTaskCompletionUseCase(id);
      await loadTasks();
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  Future<void> deleteCompletedTasks() async {
    try {
      await _deleteCompletedTasksUseCase();
      await loadTasks();
    } catch (e) {
      emit(TaskState.error(e.toString()));
    }
  }

  void watchTasks() {
    _getTasksUseCase.watchAllTasks().listen(
      (tasks) {
        final todayTasks = tasks
            .where((t) => _isToday(t.dueDate) && !t.isCompleted)
            .toList();
        final upcomingTasks = tasks
            .where((t) => _isUpcoming(t.dueDate) && !t.isCompleted)
            .toList();
        final inboxTasks = tasks
            .where((t) => t.dueDate == null && !t.isCompleted)
            .toList();
        final completedTasks = tasks.where((t) => t.isCompleted).toList();

        emit(
          TaskState.loaded(
            todayTasks: todayTasks,
            upcomingTasks: upcomingTasks,
            inboxTasks: inboxTasks,
            completedTasks: completedTasks,
          ),
        );
      },
      onError: (error) {
        emit(TaskState.error(error.toString()));
      },
    );
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isUpcoming(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return date.isAfter(tomorrow);
  }
}
