
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    final delay = dateTime.difference(now);


    if (delay.isNegative) {
      debugPrint(' Notification time is in the past, skipping.');
      return;
    }

    const String soundFileName = 'notify';

    final androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminder',
      channelDescription: 'Channel for all reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: 'ic_stat_logo',
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

    debugPrint('Notification "$title" scheduled in ${delay.inSeconds} seconds');

   
    Future.delayed(delay, () async {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      debugPrint('Notification "$title" shown at ${DateTime.now()}');
    });
  }
}


