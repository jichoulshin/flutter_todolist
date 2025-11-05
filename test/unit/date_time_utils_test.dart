import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todolist/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('formatDate should return correct format', () {
      // Arrange
      final date = DateTime(2024, 11, 5, 14, 30);

      // Act
      final result = DateTimeUtils.formatDate(date);

      // Assert
      expect(result, '2024-11-05');
    });

    test('formatTime should return correct 24-hour format', () {
      // Arrange
      final date1 = DateTime(2024, 11, 5, 14, 30);
      final date2 = DateTime(2024, 11, 5, 9, 5);

      // Act
      final result1 = DateTimeUtils.formatTime(date1);
      final result2 = DateTimeUtils.formatTime(date2);

      // Assert
      expect(result1, '14:30');
      expect(result2, '09:05');
    });

    test('formatDateTime should combine date and time', () {
      // Arrange
      final date = DateTime(2024, 11, 5, 14, 30);

      // Act
      final result = DateTimeUtils.formatDateTime(date);

      // Assert
      expect(result, '2024-11-05 14:30');
    });

    test('isToday should return true for today date', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 30);

      // Act
      final result = DateTimeUtils.isToday(today);

      // Assert
      expect(result, true);
    });

    test('isToday should return false for yesterday', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      // Act
      final result = DateTimeUtils.isToday(yesterday);

      // Assert
      expect(result, false);
    });

    test('isToday should return false for tomorrow', () {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      // Act
      final result = DateTimeUtils.isToday(tomorrow);

      // Assert
      expect(result, false);
    });

    test('isTomorrow should return true for tomorrow date', () {
      // Arrange
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));

      // Act
      final result = DateTimeUtils.isTomorrow(tomorrow);

      // Assert
      expect(result, true);
    });

    test('isTomorrow should return false for today', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateTimeUtils.isTomorrow(today);

      // Assert
      expect(result, false);
    });

    test('formatRelativeDate should return "Today" for today', () {
      // Arrange
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 14, 30);

      // Act
      final result = DateTimeUtils.formatRelativeDate(today);

      // Assert
      expect(result, 'Today');
    });

    test('formatRelativeDate should return "Tomorrow" for tomorrow', () {
      // Arrange
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1, hours: 10));

      // Act
      final result = DateTimeUtils.formatRelativeDate(tomorrow);

      // Assert
      expect(result, 'Tomorrow');
    });

    test('formatRelativeDate should return "Overdue" for past dates', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      // Act
      final result = DateTimeUtils.formatRelativeDate(yesterday);

      // Assert
      expect(result, 'Overdue');
    });

    test('isPast should return true for past date', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));

      // Act
      final result = DateTimeUtils.isPast(pastDate);

      // Assert
      expect(result, true);
    });

    test('isPast should return false for future date', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(hours: 1));

      // Act
      final result = DateTimeUtils.isPast(futureDate);

      // Assert
      expect(result, false);
    });

    test('combineDateAndTime should combine correctly', () {
      // Arrange
      final date = DateTime(2024, 11, 5);
      final time = DateTime(2000, 1, 1, 14, 30);

      // Act
      final result = DateTimeUtils.combineDateAndTime(date, time);

      // Assert
      expect(result.year, 2024);
      expect(result.month, 11);
      expect(result.day, 5);
      expect(result.hour, 14);
      expect(result.minute, 30);
    });
  });
}
