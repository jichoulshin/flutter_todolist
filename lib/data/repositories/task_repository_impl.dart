import 'package:drift/drift.dart';
import '../../domain/entities/task.dart' as entity;
import '../../domain/repositories/task_repository.dart';
import '../database/drift_database.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _database;

  TaskRepositoryImpl(this._database);

  @override
  Future<List<entity.Task>> getAllTasks() async {
    final tasks = await _database.getAllTasks();
    return tasks.map(_mapToEntity).toList();
  }

  @override
  Future<List<entity.Task>> getTodayTasks() async {
    final tasks = await _database.getTodayTasks();
    return tasks.map(_mapToEntity).toList();
  }

  @override
  Future<List<entity.Task>> getUpcomingTasks() async {
    final tasks = await _database.getUpcomingTasks();
    return tasks.map(_mapToEntity).toList();
  }

  @override
  Future<List<entity.Task>> getCompletedTasks() async {
    final tasks = await _database.getCompletedTasks();
    return tasks.map(_mapToEntity).toList();
  }

  @override
  Future<entity.Task?> getTaskById(int id) async {
    final task = await _database.getTaskById(id);
    return task != null ? _mapToEntity(task) : null;
  }

  @override
  Future<int> addTask(entity.Task task) async {
    final companion = TasksCompanion(
      title: Value(task.title),
      description: Value(task.description),
      dueDate: Value(task.dueDate),
      isCompleted: Value(task.isCompleted),
      createdAt: Value(task.createdAt),
    );
    return await _database.addTask(companion);
  }

  @override
  Future<void> updateTask(entity.Task task) async {
    if (task.id == null) return;

    final companion = TasksCompanion(
      id: Value(task.id!),
      title: Value(task.title),
      description: Value(task.description),
      dueDate: Value(task.dueDate),
      isCompleted: Value(task.isCompleted),
      createdAt: Value(task.createdAt),
    );
    await _database.updateTask(companion);
  }

  @override
  Future<void> deleteTask(int id) async {
    await _database.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(int id) async {
    await _database.toggleTaskCompletion(id);
  }

  @override
  Future<void> deleteCompletedTasks() async {
    await _database.deleteCompletedTasks();
  }

  @override
  Stream<List<entity.Task>> watchAllTasks() {
    return _database.watchAllTasks().map(
      (tasks) => tasks.map(_mapToEntity).toList(),
    );
  }

  entity.Task _mapToEntity(Task task) {
    return entity.Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
    );
  }
}
