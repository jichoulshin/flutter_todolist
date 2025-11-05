import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<List<Task>> getAllTasks() => repository.getAllTasks();
  Future<List<Task>> getTodayTasks() => repository.getTodayTasks();
  Future<List<Task>> getUpcomingTasks() => repository.getUpcomingTasks();
  Future<List<Task>> getCompletedTasks() => repository.getCompletedTasks();
  Stream<List<Task>> watchAllTasks() => repository.watchAllTasks();
}
