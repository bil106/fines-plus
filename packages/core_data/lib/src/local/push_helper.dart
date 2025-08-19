import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class PushHelper {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  PushHelper(this._notificationsPlugin);

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      debugPrint('⏱ Notification time is in the past, skipping.');
      return;
    }

    
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
const String soundFileName = 'notify';
    final androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminder',
      channelDescription: 'Channel for all reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(soundFileName),
     
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    debugPrint('🔔 Notification "$title" scheduled at $scheduledDate');
  }
}


