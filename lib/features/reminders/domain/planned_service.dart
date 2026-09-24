import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';

/// How the Home "ТО" button should look given the user's planned services.
enum PlannedStatus { none, upcoming, overdue }

/// A service the user booked for a later date without knowing its cost yet:
/// stored as a reminder (never as an expense) flagged
/// [ReminderModel.isPlannedService].
class PlannedService {
  static const reminderHour = 9;
  static const _dailyIdBase = 300000;
  static const _leadIdBase = 2000000;

  /// How many days before its date a planned service starts reminding daily.
  static const leadDays = 7;

  /// Id of the daily notification that keeps reminding about a planned
  /// service from [leadDays] before its date until it's completed.
  static int dailyNotificationId(String reminderId) => _dailyIdBase + reminderId.hashCode.abs() % 100000;

  /// Id of the one-off notification [daysBefore] (1..[leadDays]) days before
  /// a planned service's date, used while the daily one can't be armed yet.
  static int leadNotificationId(String reminderId, int daysBefore) =>
      _leadIdBase + (reminderId.hashCode.abs() % 100000) * leadDays + daysBefore - 1;

  /// Whether a date picked in the service form means "book for later"
  /// rather than "already done".
  static bool isPlannedDate(DateTime date, DateTime now) =>
      DateTime(date.year, date.month, date.day).isAfter(DateTime(now.year, now.month, now.day));

  /// Status of the planned services of one quick-add sheet ([category], null
  /// for the main "ТО" one).
  static PlannedStatus status(Iterable<ReminderModel> reminders, DateTime now, {String? category}) {
    final today = DateTime(now.year, now.month, now.day);
    var result = PlannedStatus.none;
    for (final reminder in reminders) {
      if (!reminder.isPlannedService || reminder.isCompleted || reminder.plannedCategory != category) continue;
      final due = reminder.dateTime.toLocal();
      if (DateTime(due.year, due.month, due.day).isBefore(today)) return PlannedStatus.overdue;
      result = PlannedStatus.upcoming;
    }
    return result;
  }
}
