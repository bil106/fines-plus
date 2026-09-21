import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:intl/intl.dart';

/// OS-level "your insurance is about to expire" notification, a fortnight
/// before the current policy's end date. Always follows the policy the app
/// currently treats as current, so changing its end date moves the reminder.
class InsuranceExpiryReminder {
  static const notificationId = 9100;
  static const _leadDays = ReminderItem.soonDays;
  static const _hour = 9;

  final PushHelper _pushHelper;

  InsuranceExpiryReminder(this._pushHelper);

  /// When the notification should fire for a policy ending on [validTo]: two
  /// weeks ahead at 09:00, or - if that moment has already passed while the
  /// policy is still valid - the next 09:00. Null once it has expired.
  static DateTime? fireAt(DateTime validTo, DateTime now) {
    final lastDay = DateTime(validTo.year, validTo.month, validTo.day, 23, 59);
    if (lastDay.isBefore(now)) return null;

    final lead = DateTime(validTo.year, validTo.month, validTo.day - _leadDays, _hour);
    if (lead.isAfter(now)) return lead;

    var next = DateTime(now.year, now.month, now.day, _hour);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next.isAfter(lastDay) ? null : next;
  }

  /// Replaces any pending notification with one for [validTo] (or just
  /// cancels it when there is no policy / it has expired).
  Future<void> sync(DateTime? validTo, {DateTime? now}) async {
    await _pushHelper.cancelNotification(notificationId);
    if (validTo == null) return;

    final fireDate = fireAt(validTo, now ?? DateTime.now());
    if (fireDate == null) return;

    await _pushHelper.scheduleNotification(
      id: notificationId,
      title: S.current.reminder_insurance_expires,
      body: S.current.insurance_expiry_reminder_body(DateFormat('dd.MM.yyyy').format(validTo)),
      dateTime: fireDate,
    );
  }
}
