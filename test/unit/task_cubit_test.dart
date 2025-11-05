import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_todolist/domain/entities/task.dart';
import 'package:flutter_todolist/presentation/cubits/task_cubit.dart';
import 'package:flutter_todolist/presentation/cubits/task_state.dart';
import 'package:flutter_todolist/domain/usecases/add_task_usecase.dart';
import 'package:flutter_todolist/domain/usecases/get_tasks_usecase.dart';
import 'package:flutter_todolist/domain/usecases/update_task_usecase.dart';
import 'package:flutter_todolist/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_todolist/domain/usecases/delete_completed_tasks_usecase.dart';
import 'package:flutter_todolist/domain/usecases/toggle_task_completion_usecase.dart';
import '../mocks/mock_annotations.mocks.dart';

void main() {
  late TaskCubit cubit;
  late MockTaskRepository mockRepository;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockRepository = MockTaskRepository();
    mockNotificationService = MockNotificationService();

    cubit = TaskCubit(
      getTasksUseCase: GetTasksUseCase(mockRepository),
      addTaskUseCase: AddTaskUseCase(mockRepository),
      updateTaskUseCase: UpdateTaskUseCase(mockRepository),
      deleteTaskUseCase: DeleteTaskUseCase(mockRepository),
      deleteCompletedTasksUseCase: DeleteCompletedTasksUseCase(mockRepository),
      toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase(mockRepository),
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('TaskCubit', () {
    test('initial state should be TaskState.initial', () {
      expect(cubit.state, const TaskState.initial());
    });

    test('loadTasks should load tasks successfully', () async {
      // Arrange
      final now = DateTime.now();
      final tasks = [
        Task(
          id: 1,
          title: 'Task 1',
          description: null,
          dueDate: now,
          isCompleted: false,
          createdAt: now,
        ),
      ];

      when(mockRepository.getTodayTasks()).thenAnswer((_) async => tasks);
      when(mockRepository.getUpcomingTasks()).thenAnswer((_) async => []);
      when(mockRepository.getAllTasks()).thenAnswer((_) async => tasks);
      when(mockRepository.getCompletedTasks()).thenAnswer((_) async => []);

      // Act
      await cubit.loadTasks();

      // Assert
      cubit.state.when(
        initial: () => fail('Should not be initial'),
        loading: () => fail('Should not be loading'),
        loaded: (todayTasks, upcomingTasks, inboxTasks, completedTasks) {
          expect(todayTasks.length, 1);
          expect(todayTasks.first.title, 'Task 1');
        },
        error: (_) => fail('Should not be error'),
      );
    });

    test('loadTasks should emit error state when repository fails', () async {
      // Arrange
      when(
        mockRepository.getTodayTasks(),
      ).thenThrow(Exception('Database error'));

      // Act
      await cubit.loadTasks();

      // Assert
      cubit.state.when(
        initial: () => fail('Should not be initial'),
        loading: () => fail('Should not be loading'),
        loaded: (_, __, ___, ____) => fail('Should not be loaded'),
        error: (message) {
          expect(message, contains('Exception'));
        },
      );
    });

    test('addTask should schedule notification and reload tasks', () async {
      // Arrange
      final task = Task(
        title: 'New Task',
        description: null,
        dueDate: DateTime.now().add(const Duration(hours: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      when(mockRepository.addTask(any)).thenAnswer((_) async => 1);
      when(
        mockNotificationService.scheduleTaskReminder(any),
      ).thenAnswer((_) async => Future.value());
      when(mockRepository.getTodayTasks()).thenAnswer((_) async => []);
      when(mockRepository.getUpcomingTasks()).thenAnswer((_) async => []);
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
      when(mockRepository.getCompletedTasks()).thenAnswer((_) async => []);

      // Act
      await cubit.addTask(task);

      // Assert
      verify(mockRepository.addTask(any)).called(1);
      verify(mockNotificationService.scheduleTaskReminder(any)).called(1);
    });

    test('addTask should not schedule notification when no due date', () async {
      // Arrange
      final task = Task(
        title: 'Task without due date',
        description: null,
        dueDate: null,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      when(mockRepository.addTask(any)).thenAnswer((_) async => 1);
      when(mockRepository.getTodayTasks()).thenAnswer((_) async => []);
      when(mockRepository.getUpcomingTasks()).thenAnswer((_) async => []);
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
      when(mockRepository.getCompletedTasks()).thenAnswer((_) async => []);

      // Act
      await cubit.addTask(task);

      // Assert
      verify(mockRepository.addTask(any)).called(1);
      verifyNever(mockNotificationService.scheduleTaskReminder(any));
    });

    test(
      'updateTask should cancel old notification and schedule new one',
      () async {
        // Arrange
        final task = Task(
          id: 1,
          title: 'Updated Task',
          description: null,
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.updateTask(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockNotificationService.cancelTaskReminder(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockNotificationService.scheduleTaskReminder(any),
        ).thenAnswer((_) async => Future.value());
        when(mockRepository.getTodayTasks()).thenAnswer((_) async => []);
        when(mockRepository.getUpcomingTasks()).thenAnswer((_) async => []);
        when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
        when(mockRepository.getCompletedTasks()).thenAnswer((_) async => []);

        // Act
        await cubit.updateTask(task);

        // Assert
        verify(mockNotificationService.cancelTaskReminder(1)).called(1);
        verify(mockNotificationService.scheduleTaskReminder(task)).called(1);
      },
    );

    test('deleteTask should cancel notification', () async {
      // Arrange
      const taskId = 1;

      when(
        mockNotificationService.cancelTaskReminder(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockRepository.deleteTask(any),
      ).thenAnswer((_) async => Future.value());
      when(mockRepository.getTodayTasks()).thenAnswer((_) async => []);
      when(mockRepository.getUpcomingTasks()).thenAnswer((_) async => []);
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
      when(mockRepository.getCompletedTasks()).thenAnswer((_) async => []);

      // Act
      await cubit.deleteTask(taskId);

      // Assert
      verify(mockNotificationService.cancelTaskReminder(taskId)).called(1);
      verify(mockRepository.deleteTask(taskId)).called(1);
    });

    test('toggleTaskCompletion should toggle task and reload', () async {
      // Arrange
      const taskId = 1;

      when(
        mockRepository.toggleTaskCompletion(any),
      ).thenAnswer((_) async => Future.value());
      when(mockRepository.getTodayTasks()).thenAnswer((_) async => []);
      when(mockRepository.getUpcomingTasks()).thenAnswer((_) async => []);
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
      when(mockRepository.getCompletedTasks()).thenAnswer((_) async => []);

      // Act
      await cubit.toggleTaskCompletion(taskId);

      // Assert
      verify(mockRepository.toggleTaskCompletion(taskId)).called(1);
    });

    test('deleteCompletedTasks should delete all completed tasks', () async {
      // Arrange
      when(
        mockRepository.deleteCompletedTasks(),
      ).thenAnswer((_) async => Future.value());
      when(mockRepository.getTodayTasks()).thenAnswer((_) async => []);
      when(mockRepository.getUpcomingTasks()).thenAnswer((_) async => []);
      when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
      when(mockRepository.getCompletedTasks()).thenAnswer((_) async => []);

      // Act
      await cubit.deleteCompletedTasks();

      // Assert
      verify(mockRepository.deleteCompletedTasks()).called(1);
    });
  });
}
