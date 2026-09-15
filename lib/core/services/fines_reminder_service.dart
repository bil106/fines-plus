import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The weekly "check for new fines" nudge — shown once the user actually
/// reaches Home (not at raw app boot, which could fire before they've even
/// finished onboarding), throttled to at most once every 7 days.
class FinesReminderService {
  static const _lastShownKey = 'last_fines_reminder_ms';
  static const _weekMs = 7 * 24 * 60 * 60 * 1000;

  static Future<void> maybeShow(PushHelper pushHelper) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastShownKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastMs < _weekMs) return;

    try {
      // S.current isn't reliably available this early relative to the
      // widget tree in every call site — a fixed string is used
      // deliberately, matching the previous app-boot version of this.
      await pushHelper.showNow(
        id: 9000,
        title: 'Нагадування про штрафи',
        body: 'Перевірте наявність нових штрафів ПДД',
      );
      await prefs.setInt(_lastShownKey, now);
      debugPrint('Weekly fines reminder shown');
    } catch (e, s) {
      debugPrint('Failed to show fines reminder: $e\n$s');
    }
  }
}
