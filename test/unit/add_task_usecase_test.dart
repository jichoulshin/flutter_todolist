import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_todolist/domain/entities/task.dart';
import 'package:flutter_todolist/domain/usecases/add_task_usecase.dart';
import '../mocks/mock_annotations.mocks.dart';

void main() {
  late AddTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = AddTaskUseCase(mockRepository);
  });

  group('AddTaskUseCase', () {
    test('should add task to repository and return task id', () async {
      // Arrange
      final task = Task(
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      const expectedId = 1;

      when(mockRepository.addTask(any)).thenAnswer((_) async => expectedId);

      // Act
      final result = await useCase(task);

      // Assert
      expect(result, expectedId);
      verify(mockRepository.addTask(task)).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      final task = Task(
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      when(mockRepository.addTask(any)).thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => useCase(task), throwsException);
    });
  });
}
