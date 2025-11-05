import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'drift_database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD Operations
  Future<List<Task>> getAllTasks() => select(tasks).get();

  Future<List<Task>> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return (select(tasks)..where(
          (t) =>
              t.dueDate.isBiggerOrEqualValue(today) &
              t.dueDate.isSmallerThanValue(tomorrow) &
              t.isCompleted.equals(false),
        ))
        .get();
  }

  Future<List<Task>> getUpcomingTasks() {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    return (select(tasks)
          ..where(
            (t) =>
                t.dueDate.isBiggerOrEqualValue(tomorrow) &
                t.isCompleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  Future<List<Task>> getCompletedTasks() {
    return (select(tasks)
          ..where((t) => t.isCompleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Task?> getTaskById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> addTask(TasksCompanion task) {
    return into(tasks).insert(task);
  }

  Future<bool> updateTask(TasksCompanion task) {
    return update(tasks).replace(task);
  }

  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> toggleTaskCompletion(int id) async {
    final task = await getTaskById(id);
    if (task != null) {
      await (update(tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(isCompleted: Value(!task.isCompleted)),
      );
    }
  }

  Future<int> deleteCompletedTasks() {
    return (delete(tasks)..where((t) => t.isCompleted.equals(true))).go();
  }

  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)..orderBy([
          (t) => OrderingTerm.asc(t.isCompleted),
          (t) => OrderingTerm.asc(t.dueDate),
        ]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smart_task.db'));
    return NativeDatabase(file);
  });
}
