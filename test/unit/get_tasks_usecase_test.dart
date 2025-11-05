import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_todolist/domain/entities/task.dart';
import 'package:flutter_todolist/domain/usecases/get_tasks_usecase.dart';
import '../mocks/mock_annotations.mocks.dart';

void main() {
  late GetTasksUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = GetTasksUseCase(mockRepository);
  });

  group('GetTasksUseCase', () {
    test('should return all tasks from repository', () async {
      // Arrange
      final now = DateTime.now();
      final tasks = [
        Task(
          id: 1,
          title: 'Task 1',
          description: 'Description 1',
          dueDate: now,
          isCompleted: false,
          createdAt: now,
        ),
        Task(
          id: 2,
          title: 'Task 2',
          description: 'Description 2',
          dueDate: now.add(const Duration(days: 1)),
          isCompleted: true,
          createdAt: now,
        ),
      ];

      when(mockRepository.getAllTasks()).thenAnswer((_) async => tasks);

      // Act
      final result = await useCase.getAllTasks();

      // Assert
      expect(result, tasks);
      expect(result.length, 2);
      verify(mockRepository.getAllTasks()).called(1);
    });

    test('should return today tasks only', () async {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayTasks = [
        Task(
          id: 1,
          title: 'Today Task',
          description: 'Due today',
          dueDate: today.add(const Duration(hours: 10)),
          isCompleted: false,
          createdAt: now,
        ),
      ];

      when(mockRepository.getTodayTasks()).thenAnswer((_) async => todayTasks);

      // Act
      final result = await useCase.getTodayTasks();

      // Assert
      expect(result, todayTasks);
      expect(result.length, 1);
      expect(result.first.title, 'Today Task');
      verify(mockRepository.getTodayTasks()).called(1);
    });

    test('should return completed tasks', () async {
      // Arrange
      final now = DateTime.now();
      final completedTasks = [
        Task(
          id: 1,
          title: 'Completed Task',
          description: 'Already done',
          dueDate: now,
          isCompleted: true,
          createdAt: now,
        ),
      ];

      when(
        mockRepository.getCompletedTasks(),
      ).thenAnswer((_) async => completedTasks);

      // Act
      final result = await useCase.getCompletedTasks();

      // Assert
      expect(result, completedTasks);
      expect(result.first.isCompleted, true);
      verify(mockRepository.getCompletedTasks()).called(1);
    });

    test('should return empty list when no tasks', () async {
      // Arrange
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.getAllTasks();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getAllTasks()).called(1);
    });
  });
}
