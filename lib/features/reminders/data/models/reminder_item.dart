import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';

enum ReminderKind { manual, insurance, oil }

enum ReminderStatus { overdue, soon, upcoming, done }

/// One row of the Reminders list: either a user-created [ReminderModel]
/// ([manual]) or an automatic one computed from insurance / maintenance
/// data (never persisted, so it can't drift from its source).
class ReminderItem {
  static const int soonDays = 14;
  static const int soonKm = 500;

  final String id;
  final ReminderKind kind;
  final ReminderModel? manual;
  final DateTime? dueDate;
  final int? remainingKm;
  final int? estimatedDays;

  const ReminderItem({
    required this.id,
    required this.kind,
    this.manual,
    this.dueDate,
    this.remainingKm,
    this.estimatedDays,
  });

  factory ReminderItem.fromManual(ReminderModel reminder) =>
      ReminderItem(id: reminder.id, kind: ReminderKind.manual, manual: reminder, dueDate: reminder.dateTime.toLocal());

  bool get isManual => kind == ReminderKind.manual;

  /// Whole calendar days from [now] to [dueDate]; negative when past.
  int? daysLeft(DateTime now) {
    final due = dueDate;
    if (due == null) return null;
    return DateTime.utc(due.year, due.month, due.day).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  }

  ReminderStatus status(DateTime now) {
    final days = daysLeft(now);
    if (isManual) {
      final reminder = manual!;
      if (reminder.isCompleted) return ReminderStatus.done;
      if (reminder.dateTime.toLocal().isBefore(now)) return ReminderStatus.overdue;
      return days! <= soonDays ? ReminderStatus.soon : ReminderStatus.upcoming;
    }
    final km = remainingKm;
    if ((km != null && km <= 0) || (days != null && days < 0)) return ReminderStatus.overdue;
    if ((km != null && km <= soonKm) || (days != null && days <= soonDays)) return ReminderStatus.soon;
    return ReminderStatus.upcoming;
  }

  /// Ordering key inside one status group: nearest first.
  int sortDays(DateTime now) => daysLeft(now) ?? estimatedDays ?? 100000;
}
