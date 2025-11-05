import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../core/constants/app_constants.dart';
import '../domain/entities/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성 (필수!)
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      const androidChannel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await androidImplementation.createNotificationChannel(androidChannel);
      debugPrint(
        '✅ Notification channel created: ${AppConstants.notificationChannelId}',
      );
    }
  }

  Future<bool> requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final granted = await androidImplementation
          .requestNotificationsPermission();
      debugPrint('🔔 Android Notification Permission: $granted');

      // Exact alarm 권한도 확인
      final exactAlarmPermission = await androidImplementation
          .requestExactAlarmsPermission();
      debugPrint('⏰ Android Exact Alarm Permission: $exactAlarmPermission');

      return granted ?? false;
    }

    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 iOS Notification Permission: $granted');
      return granted ?? false;
    }

    return true;
  }

  Future<bool> checkPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      debugPrint('🔍 Notifications Enabled: $granted');

      // Exact Alarm 권한도 체크
      final canScheduleExact = await androidImplementation
          .canScheduleExactNotifications();
      debugPrint('🔍 Can Schedule Exact Alarms: $canScheduleExact');

      if (canScheduleExact == false) {
        debugPrint('⚠️ WARNING: Exact alarm permission is NOT granted!');
        debugPrint(
          '⚠️ Scheduled notifications will NOT work without this permission!',
        );
      }

      return (granted ?? false) && (canScheduleExact ?? false);
    }

    return true;
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (task.id == null || task.dueDate == null) return;

    // 권한 확인
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      debugPrint('❌ No notification permission - requesting...');
      final granted = await requestPermissions();
      if (!granted) {
        debugPrint('❌ User denied notification permission');
        return;
      }
    }

    // Schedule notification 15 minutes before due date
    final scheduledDate = task.dueDate!.subtract(
      AppConstants.notificationReminderBefore,
    );

    // Don't schedule if the time has already passed
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ Notification NOT scheduled - time already passed');
      debugPrint('   Due: ${task.dueDate}');
      debugPrint('   Scheduled: $scheduledDate');
      debugPrint('   Now: ${DateTime.now()}');
      return;
    }

    debugPrint('✅ Scheduling notification for task #${task.id}');
    debugPrint('   Title: ${task.title}');
    debugPrint('   Due Date: ${task.dueDate}');
    debugPrint(
      '   Notification Time: $scheduledDate (${AppConstants.notificationReminderBefore.inMinutes} min before)',
    );
    debugPrint(
      '   Time until notification: ${scheduledDate.difference(DateTime.now())}',
    );

    try {
      // tz.local 기준의 TZDateTime으로 변환
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        task.id!,
        'Task Reminder',
        task.title,
        tzScheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('✅ Notification scheduled successfully!');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification: $e');
    }
  }

  Future<void> cancelTaskReminder(int taskId) async {
    await _notifications.cancel(taskId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // 테스트용: 즉시 알림 전송 (스케줄 없이)
  Future<void> sendImmediateTestNotification() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      debugPrint('❌ No notification permission - requesting...');
      final granted = await requestPermissions();
      if (!granted) {
        debugPrint('❌ User denied notification permission');
        return;
      }
    }

    debugPrint('🧪 Sending IMMEDIATE test notification...');

    await _notifications.show(
      AppConstants.immediateTestNotificationId,
      '🔔 Immediate Test',
      'This should appear RIGHT NOW!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    debugPrint('✅ Immediate notification sent!');
  }

  // 테스트용: 5초 후 알림 전송
  Future<void> sendTestNotification() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      debugPrint('❌ No notification permission - requesting...');
      final granted = await requestPermissions();
      if (!granted) {
        debugPrint('❌ User denied notification permission');
        return;
      }
    }

    debugPrint('🧪 Sending test notification in 5 seconds...');

    // 현재 시간(로컬)에서 5초 후
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(const Duration(seconds: 5));

    debugPrint('⏰ Current time (local): $now');
    debugPrint('⏰ Scheduled time (local): $scheduledTime');
    debugPrint('⏰ Time difference: ${scheduledTime.difference(now)}');

    try {
      await _notifications.zonedSchedule(
        AppConstants.testNotificationId,
        '🔔 Test Notification',
        'If you see this, notifications are working!',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('✅ zonedSchedule completed successfully!');

      // 실제로 스케줄링이 되었는지 확인
      final pendingNotifications = await _notifications
          .pendingNotificationRequests();
      debugPrint(
        '📋 Pending notifications count: ${pendingNotifications.length}',
      );
      final testNotif = pendingNotifications
          .where((n) => n.id == AppConstants.testNotificationId)
          .toList();
      if (testNotif.isNotEmpty) {
        debugPrint(
          '✅ Test notification (ID: ${AppConstants.testNotificationId}) is in pending list!',
        );
      } else {
        debugPrint(
          '❌ Test notification (ID: ${AppConstants.testNotificationId}) NOT found in pending list!',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ zonedSchedule FAILED: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Navigate to task detail if needed
  }
}
