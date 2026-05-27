import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing appointment reminders and notifications.
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  factory ReminderService() {
    return _instance;
  }

  ReminderService._internal();

  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Blantyre'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

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

    await Permission.notification.request();

    _initialized = true;
  }

  /// Schedule reminders at 24 hours and 1 hour before an appointment.
  static Future<void> scheduleAppointmentReminders({
    required String appointmentId,
    required String patientName,
    required DateTime appointmentDateTime,
  }) async {
    if (kIsWeb) return;

    try {
      await initialize();
      final now = DateTime.now();

      final reminder24h = appointmentDateTime.subtract(const Duration(hours: 24));
      if (reminder24h.isAfter(now)) {
        await _scheduleNotification(
          id: _notificationId(appointmentId, 0),
          title: 'Appointment Reminder',
          body: 'Appointment with $patientName is in 24 hours',
          scheduledDate: reminder24h,
        );
      }

      final reminder1h = appointmentDateTime.subtract(const Duration(hours: 1));
      if (reminder1h.isAfter(now)) {
        await _scheduleNotification(
          id: _notificationId(appointmentId, 1),
          title: 'Appointment Reminder',
          body: 'Appointment with $patientName is in 1 hour',
          scheduledDate: reminder1h,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling reminders: $e');
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;

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
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelAppointmentReminders(String appointmentId) async {
    if (kIsWeb) return;

    try {
      await initialize();
      await _notificationsPlugin.cancel(_notificationId(appointmentId, 0));
      await _notificationsPlugin.cancel(_notificationId(appointmentId, 1));
    } catch (e) {
      debugPrint('Error canceling reminders: $e');
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    try {
      await initialize();
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
      debugPrint('Error showing notification: $e');
    }
  }

  static int _notificationId(String appointmentId, int offset) {
    var hash = 0;
    for (final unit in appointmentId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return (hash + offset) & 0x7fffffff;
  }

  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}
