import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_todolist/domain/usecases/delete_completed_tasks_usecase.dart';
import '../mocks/mock_annotations.mocks.dart';

void main() {
  late DeleteCompletedTasksUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = DeleteCompletedTasksUseCase(mockRepository);
  });

  group('DeleteCompletedTasksUseCase', () {
    test('should delete all completed tasks from repository', () async {
      // Arrange
      when(
        mockRepository.deleteCompletedTasks(),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase();

      // Assert
      verify(mockRepository.deleteCompletedTasks()).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      when(
        mockRepository.deleteCompletedTasks(),
      ).thenThrow(Exception('Delete completed tasks failed'));

      // Act & Assert
      expect(() => useCase(), throwsException);
    });

    test('should handle empty completed tasks list', () async {
      // Arrange
      when(
        mockRepository.deleteCompletedTasks(),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase();

      // Assert
      verify(mockRepository.deleteCompletedTasks()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should be callable multiple times', () async {
      // Arrange
      when(
        mockRepository.deleteCompletedTasks(),
      ).thenAnswer((_) async => Future.value());

      // Act
      await useCase();
      await useCase();

      // Assert
      verify(mockRepository.deleteCompletedTasks()).called(2);
    });

    test('should handle database connection errors', () async {
      // Arrange
      when(
        mockRepository.deleteCompletedTasks(),
      ).thenThrow(Exception('Database connection error'));

      // Act & Assert
      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
