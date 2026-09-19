import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Time to check your fines" reminder. The MVS check needs a human to solve
/// a captcha, so it can't run in the background - instead an OS-level
/// notification is scheduled [interval] after each check and fires even when
/// the app is closed.
class FinesCheckReminder {
  static const notificationId = 9000;
  static const lastShownKey = 'last_fines_reminder_ms';
  static const interval = Duration(days: 7);

  final PushHelper _pushHelper;

  FinesCheckReminder(this._pushHelper);

  /// Restarts the countdown from now, replacing any pending reminder.
  Future<void> rescheduleFromNow(S l10n) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    // Also holds off the app-start reminder, which shares this key.
    await prefs.setInt(lastShownKey, now.millisecondsSinceEpoch);
    await _pushHelper.cancelNotification(notificationId);
    await _pushHelper.scheduleNotification(
      id: notificationId,
      title: l10n.fines_reminder_title,
      body: l10n.fines_reminder_body,
      dateTime: now.add(interval),
    );
  }
}
