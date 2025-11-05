import '../repositories/task_repository.dart';

class DeleteCompletedTasksUseCase {
  final TaskRepository _repository;

  DeleteCompletedTasksUseCase(this._repository);

  Future<void> call() async {
    await _repository.deleteCompletedTasks();
  }
}
