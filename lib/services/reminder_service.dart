import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

/// Service for managing appointment reminders and notifications
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory ReminderService() {
    return _instance;
  }

  ReminderService._internal();

  /// Initialize the reminder service
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  /// Schedule reminders for an appointment
  /// Schedules notifications at:
  /// - 24 hours before the event
  /// - 1 hour before the event
  static Future<void> scheduleAppointmentReminders({
    required String appointmentId,
    required String patientName,
    required DateTime appointmentDateTime,
  }) async {
    try {
      final now = DateTime.now();

      // 24 hours before reminder
      final reminder24h = appointmentDateTime.subtract(const Duration(hours: 24));
      if (reminder24h.isAfter(now)) {
        await _scheduleNotification(
          id: appointmentId.hashCode,
          title: 'Appointment Reminder',
          body: 'Appointment with $patientName is in 24 hours',
          scheduledDate: reminder24h,
        );
      }

      // 1 hour before reminder
      final reminder1h = appointmentDateTime.subtract(const Duration(hours: 1));
      if (reminder1h.isAfter(now)) {
        await _scheduleNotification(
          id: appointmentId.hashCode + 1,
          title: 'Appointment Reminder',
          body: 'Appointment with $patientName is in 1 hour',
          scheduledDate: reminder1h,
        );
      }
    } catch (e) {
      print('❌ Error scheduling reminders: $e');
    }
  }

  /// Schedule a single notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'appointment_reminders',
        'Appointment Reminders',
        channelDescription: 'Notifications for upcoming appointments',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _convertToTZDateTime(scheduledDate),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel reminders for an appointment
  static Future<void> cancelAppointmentReminders(String appointmentId) async {
    try {
      await _notificationsPlugin.cancel(appointmentId.hashCode);
      await _notificationsPlugin.cancel(appointmentId.hashCode + 1);
    } catch (e) {
      print('❌ Error canceling reminders: $e');
    }
  }

  /// Show an immediate notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'general_notifications',
        'General Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
      );
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Convert DateTime to TZDateTime for scheduling
  static dynamic _convertToTZDateTime(DateTime dateTime) {
    // For simplicity, using the DateTime directly
    // In production, you might want to use timezone package
    return dateTime;
  }
}
