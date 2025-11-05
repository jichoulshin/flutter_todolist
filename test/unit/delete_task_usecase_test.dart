import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_todolist/domain/usecases/delete_task_usecase.dart';
import '../mocks/mock_annotations.mocks.dart';

void main() {
  late DeleteTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = DeleteTaskUseCase(mockRepository);
  });

  group('DeleteTaskUseCase', () {
    test('should delete task from repository', () async {
      // Arrange
      const taskId = 1;

      when(
        mockRepository.deleteTask(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(taskId);

      // Assert
      verify(mockRepository.deleteTask(taskId)).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      const taskId = 1;

      when(
        mockRepository.deleteTask(any),
      ).thenThrow(Exception('Delete failed'));

      // Act & Assert
      expect(() => useCase(taskId), throwsException);
    });

    test('should handle deletion of non-existent task', () async {
      // Arrange
      const nonExistentId = 9999;

      when(
        mockRepository.deleteTask(any),
      ).thenThrow(Exception('Task not found'));

      // Act & Assert
      expect(() => useCase(nonExistentId), throwsException);
    });

    test('should delete task with valid positive id', () async {
      // Arrange
      const taskId = 42;

      when(
        mockRepository.deleteTask(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(taskId);

      // Assert
      verify(mockRepository.deleteTask(taskId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
