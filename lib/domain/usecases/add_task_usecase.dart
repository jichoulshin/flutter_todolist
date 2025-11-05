import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  Future<int> call(Task task) async {
    return await repository.addTask(task);
  }
}
