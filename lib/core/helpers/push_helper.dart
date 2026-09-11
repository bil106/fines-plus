
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushHelper {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  PushHelper(this._notificationsPlugin);

  static const _androidMaintenance = AndroidNotificationDetails(
    'maintenance_channel',
    'Maintenance',
    channelDescription: 'Maintenance schedule reminders',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_stat_logo',
  );

  static const _androidReminders = AndroidNotificationDetails(
    'reminders_channel',
    'Reminder',
    channelDescription: 'Channel for all reminders',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    icon: 'ic_stat_logo',
    sound: RawResourceAndroidNotificationSound('notify'),
  );

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    bool isMaintenance = false,
    String? payload,
  }) async {
    final details = NotificationDetails(
      android: isMaintenance ? _androidMaintenance : _androidReminders,
      iOS: _iosDetails,
    );
    await _notificationsPlugin.show(id, title, body, details, payload: payload);
    debugPrint('Notification shown: "$title"');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    final now = DateTime.now();
    final delay = dateTime.difference(now);

    if (delay.isNegative) {
      return;
    }

    final details = NotificationDetails(
      android: _androidReminders,
      iOS: _iosDetails,
    );

    debugPrint('Notification "$title" scheduled in ${delay.inSeconds} seconds');

    Future.delayed(delay, () async {
      await _notificationsPlugin.show(id, title, body, details, payload: payload);
      debugPrint('Notification "$title" shown at ${DateTime.now()}');
    });
  }
}


