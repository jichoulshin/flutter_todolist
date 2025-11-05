class AppConstants {
  // Database
  static const String databaseName = 'flutter_todolist.db';
  static const int databaseVersion = 1;

  // Notifications
  static const String notificationChannelId = 'task_reminders';
  static const String notificationChannelName = 'Task Reminders';
  static const String notificationChannelDescription =
      'Notifications for task reminders';
  static const Duration notificationReminderBefore = Duration(minutes: 15);
  static const int testNotificationId = 99999;
  static const int immediateTestNotificationId = 99998;

  // Date/Time
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // Screen Design
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;
}
