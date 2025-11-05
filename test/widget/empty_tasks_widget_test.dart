import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_todolist/presentation/widgets/empty_tasks_widget.dart';

void main() {
  group('EmptyTasksWidget', () {
    testWidgets('should display default message', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: const MaterialApp(home: Scaffold(body: EmptyTasksWidget())),
        ),
      );

      // Assert
      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });

    testWidgets('should display custom message', (WidgetTester tester) async {
      // Arrange
      const customMessage = 'All tasks completed!';

      // Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: const MaterialApp(
            home: Scaffold(body: EmptyTasksWidget(message: customMessage)),
          ),
        ),
      );

      // Assert
      expect(find.text(customMessage), findsOneWidget);
      expect(find.text('No tasks yet'), findsNothing);
    });

    testWidgets('should have correct icon size', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: const MaterialApp(home: Scaffold(body: EmptyTasksWidget())),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.task_alt));
      expect(iconWidget.size, isNotNull);
    });
  });
}
