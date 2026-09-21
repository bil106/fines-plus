import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';

/// How the Home "ТО" button should look given the user's planned services.
enum PlannedStatus { none, upcoming, overdue }

/// A service the user booked for a later date without knowing its cost yet:
/// stored as a reminder (never as an expense) flagged
/// [ReminderModel.isPlannedService].
class PlannedService {
  static const reminderHour = 9;
  static const _dailyIdBase = 300000;

  /// Id of the daily "you still haven't done it" notification that follows a
  /// planned service reminder once its date has passed.
  static int dailyNotificationId(String reminderId) => _dailyIdBase + reminderId.hashCode.abs() % 100000;

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
