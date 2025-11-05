import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_todolist/domain/entities/task.dart';
import 'package:flutter_todolist/domain/usecases/update_task_usecase.dart';
import '../mocks/mock_annotations.mocks.dart';

void main() {
  late UpdateTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = UpdateTaskUseCase(mockRepository);
  });

  group('UpdateTaskUseCase', () {
    test('should update task in repository', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Updated Task',
        description: 'Updated Description',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      when(
        mockRepository.updateTask(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(task);

      // Assert
      verify(mockRepository.updateTask(task)).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Task to update',
        description: null,
        dueDate: null,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      when(
        mockRepository.updateTask(any),
      ).thenThrow(Exception('Update failed'));

      // Act & Assert
      expect(() => useCase(task), throwsException);
    });

    test('should update task completion status', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Task',
        description: null,
        dueDate: null,
        isCompleted: true, // Changed to completed
        createdAt: DateTime.now(),
      );

      when(
        mockRepository.updateTask(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(task);

      // Assert
      verify(
        mockRepository.updateTask(
          argThat(predicate<Task>((t) => t.isCompleted == true)),
        ),
      ).called(1);
    });

    test('should update task due date', () async {
      // Arrange
      final newDueDate = DateTime.now().add(const Duration(days: 5));
      final task = Task(
        id: 1,
        title: 'Task',
        description: null,
        dueDate: newDueDate,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      when(
        mockRepository.updateTask(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(task);

      // Assert
      verify(
        mockRepository.updateTask(
          argThat(predicate<Task>((t) => t.dueDate == newDueDate)),
        ),
      ).called(1);
    });
  });
}
