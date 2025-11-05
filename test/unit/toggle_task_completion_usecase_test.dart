import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_todolist/domain/usecases/toggle_task_completion_usecase.dart';
import '../mocks/mock_annotations.mocks.dart';

void main() {
  late ToggleTaskCompletionUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = ToggleTaskCompletionUseCase(mockRepository);
  });

  group('ToggleTaskCompletionUseCase', () {
    test('should toggle task completion status in repository', () async {
      // Arrange
      const taskId = 1;

      when(
        mockRepository.toggleTaskCompletion(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(taskId);

      // Assert
      verify(mockRepository.toggleTaskCompletion(taskId)).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      const taskId = 1;

      when(
        mockRepository.toggleTaskCompletion(any),
      ).thenThrow(Exception('Toggle failed'));

      // Act & Assert
      expect(() => useCase(taskId), throwsException);
    });

    test('should handle toggling non-existent task', () async {
      // Arrange
      const nonExistentId = 9999;

      when(
        mockRepository.toggleTaskCompletion(any),
      ).thenThrow(Exception('Task not found'));

      // Act & Assert
      expect(() => useCase(nonExistentId), throwsException);
    });

    test('should toggle multiple times for same task', () async {
      // Arrange
      const taskId = 1;

      when(
        mockRepository.toggleTaskCompletion(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(taskId); // First toggle
      await useCase(taskId); // Second toggle
      await useCase(taskId); // Third toggle

      // Assert
      verify(mockRepository.toggleTaskCompletion(taskId)).called(3);
    });

    test('should work with different task ids', () async {
      // Arrange
      when(
        mockRepository.toggleTaskCompletion(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase(1);
      await useCase(2);
      await useCase(3);

      // Assert
      verify(mockRepository.toggleTaskCompletion(1)).called(1);
      verify(mockRepository.toggleTaskCompletion(2)).called(1);
      verify(mockRepository.toggleTaskCompletion(3)).called(1);
    });
  });
}
