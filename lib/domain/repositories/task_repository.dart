import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getTodayTasks();
  Future<List<Task>> getUpcomingTasks();
  Future<List<Task>> getCompletedTasks();
  Future<Task?> getTaskById(int id);
  Future<int> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<void> toggleTaskCompletion(int id);
  Future<void> deleteCompletedTasks();
  Stream<List<Task>> watchAllTasks();
}
