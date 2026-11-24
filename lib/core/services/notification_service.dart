import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/tasks/domain/task_model.dart';

/// Production notification service managing local reminders for scheduled tasks.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize local notification channels, timezone database, and permissions.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();

      // 2. Android initialization settings
      const androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS/Darwin initialization settings
      const darwinInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: darwinInitSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Create Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        'taskora_reminders',
        'Task Reminders',
        description: 'Scheduled reminders and alerts for Taskora tasks',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  /// Request permissions for iOS and Android 13+
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Schedule a local notification for a specific task.
  Future<void> scheduleTaskReminder(Task task) async {
    if (!_isInitialized || task.reminderTime == null) return;

    final scheduledDate = task.reminderTime!;
    if (scheduledDate.isBefore(DateTime.now())) return;

    try {
      final notificationId = task.id.hashCode.abs() % 100000;

      const androidDetails = AndroidNotificationDetails(
        'taskora_reminders',
        'Task Reminders',
        channelDescription: 'Scheduled reminders for Taskora tasks',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'Reminder: ${task.title}',
        task.description.isNotEmpty
            ? task.description
            : 'Your task is scheduled for now.',
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
      );
    } catch (e) {
      debugPrint('Error scheduling task reminder for ${task.title}: $e');
    }
  }

  /// Cancel any scheduled reminder for the given task.
  Future<void> cancelTaskReminder(String taskId) async {
    try {
      final notificationId = taskId.hashCode.abs() % 100000;
      await _notificationsPlugin.cancel(notificationId);
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Show an instant notification (e.g. for completed focus timer session).
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'taskora_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for completed focus sessions and goals',
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      await _notificationsPlugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }
}
