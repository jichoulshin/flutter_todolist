import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_todolist/domain/entities/task.dart';
import 'package:flutter_todolist/presentation/widgets/task_card.dart';

void main() {
  group('TaskCard', () {
    testWidgets('should display task title and description', (
      WidgetTester tester,
    ) async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: TaskCard(task: task, onTap: () {}, onToggle: () {}),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should show unchecked circle when task is incomplete', (
      WidgetTester tester,
    ) async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Incomplete Task',
        description: null,
        dueDate: null,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: TaskCard(task: task, onTap: () {}, onToggle: () {}),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('should show check icon when task is completed', (
      WidgetTester tester,
    ) async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Completed Task',
        description: null,
        dueDate: null,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: TaskCard(task: task, onTap: () {}, onToggle: () {}),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      var tapped = false;
      final task = Task(
        id: 1,
        title: 'Tappable Task',
        description: null,
        dueDate: null,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: TaskCard(
                task: task,
                onTap: () => tapped = true,
                onToggle: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should call onToggle when check circle is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      var toggled = false;
      final task = Task(
        id: 1,
        title: 'Toggleable Task',
        description: null,
        dueDate: null,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: TaskCard(
                task: task,
                onTap: () {},
                onToggle: () => toggled = true,
              ),
            ),
          ),
        ),
      );

      // Find the Container that acts as checkbox (it's inside an InkWell)
      final checkboxContainer = find.byType(Container).first;
      await tester.tap(checkboxContainer);
      await tester.pumpAndSettle();

      // Assert
      expect(toggled, true);
    });

    testWidgets('should display due date icon when task has due date', (
      WidgetTester tester,
    ) async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Task with due date',
        description: null,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: TaskCard(task: task, onTap: () {}, onToggle: () {}),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should not display due date icon when task has no due date', (
      WidgetTester tester,
    ) async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Task without due date',
        description: null,
        dueDate: null,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: TaskCard(task: task, onTap: () {}, onToggle: () {}),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.schedule), findsNothing);
    });
  });
}
