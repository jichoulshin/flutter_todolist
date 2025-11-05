import '../repositories/task_repository.dart';

class ToggleTaskCompletionUseCase {
  final TaskRepository repository;

  ToggleTaskCompletionUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.toggleTaskCompletion(id);
  }
}
