
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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

  // No `sound:` override here — the channel itself was already created
  // (in AppInitializer) with this custom sound, and Android O+ locks a
  // channel's sound at creation time regardless of what a later
  // notification specifies. Re-resolving the raw resource here as well
  // is redundant and, if that resource lookup fails in the cold process
  // context a background alarm receiver runs in, is a plausible reason a
  // scheduled reminder (unlike an immediate one posted from the live app)
  // never actually reaches NotificationManager.
  static const _androidReminders = AndroidNotificationDetails(
    'reminders_channel',
    'Reminder',
    channelDescription: 'Channel for all reminders',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    icon: 'ic_stat_logo',
  );

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    // NOT .timeSensitive: that interruption level needs Apple's
    // com.apple.developer.usernotifications.time-sensitive entitlement
    // (a separate approved request, not present in Runner.entitlements) -
    // without it iOS can silently drop the notification instead of
    // delivering it at the default level, which is the opposite of what
    // was intended here.
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

  /// Schedules a real OS-level notification (Android AlarmManager /
  /// iOS UNUserNotificationCenter) via [zonedSchedule] — unlike a plain
  /// `Future.delayed` timer, this still fires after the app is closed or
  /// backgrounded, which is the whole point of a reminder set days or weeks
  /// ahead.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    if (dateTime.isBefore(DateTime.now())) {
      debugPrint('Notification "$title" NOT scheduled — $dateTime is already in the past');
      return;
    }

    final details = NotificationDetails(
      android: _androidReminders,
      iOS: _iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      payload: payload,
      androidScheduleMode: await _scheduleMode(),
    );

    debugPrint('Notification "$title" scheduled (OS-level) for $dateTime');
  }

  /// Like [scheduleNotification], but repeats every day at [firstDate]'s
  /// time of day until cancelled.
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime firstDate,
    String? payload,
  }) async {
    final details = NotificationDetails(
      android: _androidReminders,
      iOS: _iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(firstDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: await _scheduleMode(),
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Daily notification "$title" scheduled from $firstDate');
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    if (Platform.isAndroid) {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (await androidImpl?.canScheduleExactNotifications() == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> cancelNotification(int id) => _notificationsPlugin.cancel(id);
}


