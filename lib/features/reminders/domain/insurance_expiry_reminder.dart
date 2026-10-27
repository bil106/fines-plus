import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:intl/intl.dart';

/// OS-level "your insurance is about to expire" notification, a fortnight
/// before a policy's end date - one per policy, so several policies each
/// keep their own. Changing a policy's end date moves its reminder.
class InsuranceExpiryReminder {
  /// The single id used before reminders were per policy; still cancelled so
  /// an old install doesn't fire a duplicate.
  static const legacyNotificationId = 9100;
  static const _idBase = 910000000;
  static const _idSpan = 1000000;
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

  /// A stable id for [policyId] (FNV-1a, since String.hashCode isn't
  /// guaranteed across Dart versions and a stale id could never be cancelled).
  static int notificationIdFor(String policyId) {
    var hash = 0x811c9dc5;
    for (final unit in policyId.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return _idBase + hash % _idSpan;
  }

  Future<void> cancelLegacy() => _pushHelper.cancelNotification(legacyNotificationId);

  Future<void> cancel(String policyId) => _pushHelper.cancelNotification(notificationIdFor(policyId));

  /// Replaces any pending notification of [policyId] with one for [validTo]
  /// (or just cancels it when it has expired).
  Future<void> sync(String policyId, DateTime validTo, {String? company, DateTime? now}) async {
    await cancel(policyId);

    final fireDate = fireAt(validTo, now ?? DateTime.now());
    if (fireDate == null) return;

    final title = S.current.reminder_insurance_expires;
    await _pushHelper.scheduleNotification(
      id: notificationIdFor(policyId),
      title: company == null || company.isEmpty ? title : '$title · $company',
      body: S.current.insurance_expiry_reminder_body(DateFormat('dd.MM.yyyy').format(validTo)),
      dateTime: fireDate,
    );
  }
}
