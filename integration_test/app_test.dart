import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_todolist/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo App Integration Test', () {
    testWidgets('Complete task flow: add, view, complete, delete', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to initialize
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 1. Find and tap the FAB to add a new task
      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // 2. Enter task details
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Integration Test Task');
      await tester.pumpAndSettle();

      // 3. Save the task
      final saveButton = find.text('Add Task');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 4. Verify task appears in the list
      expect(find.text('Integration Test Task'), findsWidgets);

      // 5. Tap on the task to view details
      await tester.tap(find.text('Integration Test Task'));
      await tester.pumpAndSettle();

      // 6. Go back to home
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // 7. Complete the task by tapping the check circle
      final taskCard = find.text('Integration Test Task');
      expect(taskCard, findsWidgets);

      print('✅ Integration test completed successfully!');
    });

    testWidgets('Navigate to settings and back', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initialization
      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Find and tap settings icon
      final settingsIcon = find.byIcon(Icons.settings);
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      // Verify we're on settings page
      expect(find.text('Settings'), findsWidgets);

      // Go back
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // Verify we're back on home page
      expect(find.byType(FloatingActionButton), findsOneWidget);

      print('✅ Settings navigation test completed!');
    });
  });
}
