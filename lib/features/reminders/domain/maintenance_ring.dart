import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/domain/auto_reminder_builder.dart';
import 'package:flutter/painting.dart';

/// How much of a service / policy interval is still left (1 = just renewed,
/// 0 = due), for the progress rings on the Home quick-add buttons. Pure - no
/// I/O - like [AutoReminderBuilder], so it is cheap to re-run and to test.
class MaintenanceRing {
  static const redUpTo = 0.2;
  static const yellowUpTo = 0.5;

  /// A planned service has only a due date, so its ring counts down over a
  /// year: full when it is a year or more away, empty on the day itself and
  /// once it has passed.
  static const plannedHorizonDays = 365;

  /// A full insurance ring is a whole year left, whatever term the policy was
  /// actually written for.
  static const insuranceFullDays = 365;

  /// Ring colour for a [remaining] share: [danger] up to 20%, [warning] up
  /// to 50%, [success] above - defaults match the mockup's ring thresholds
  /// (AppBrandTheme.statusDanger/statusWarning/statusSuccess normally cover
  /// these; the AppColors fallbacks below only apply if a caller omits them).
  static Color color(
    double remaining, {
    Color danger = AppColors.lightRed,
    Color warning = AppColors.amber,
    Color success = AppColors.green,
  }) {
    if (remaining <= redUpTo) return danger;
    if (remaining <= yellowUpTo) return warning;
    return success;
  }

  /// Share of [task]'s time interval still left (since its last service),
  /// or null when it has no time interval to measure against.
  static double? taskRemaining(MaintenanceTask task, {DateTime? now}) {
    final last = task.lastServiceDate;
    final interval = task.intervalTime;
    if (last == null || interval == null || interval.inDays <= 0) return null;
    final passed = (now ?? DateTime.now()).difference(last).inDays;
    return (1 - passed / interval.inDays).clamp(0.0, 1.0);
  }

  /// The most urgent share among the not-yet-done planned services booked
  /// in one quick-add sheet ([category], null for the main "ТО" one), by
  /// their due dates; null when there are none.
  static double? plannedRemaining(Iterable<ReminderModel> reminders, DateTime now, {String? category}) {
    final today = DateTime.utc(now.year, now.month, now.day);
    double? worst;
    for (final reminder in reminders) {
      if (!reminder.isPlannedService || reminder.isCompleted) continue;
      if (reminder.plannedCategory?.toLowerCase() != category?.toLowerCase()) continue;
      final due = reminder.dateTime.toLocal();
      final days = DateTime.utc(due.year, due.month, due.day).difference(today).inDays;
      final remaining = (days / plannedHorizonDays).clamp(0.0, 1.0);
      if (worst == null || remaining < worst) worst = remaining;
    }
    return worst;
  }

  /// Days left on the current policy out of [insuranceFullDays] (full at a
  /// year or more, empty once it ends); falls back to an insurance schedule
  /// task when no policy was saved. Null when neither.
  static double? insuranceRemaining(
    List<InsuranceRecord> records,
    Iterable<MaintenanceTask> tasks,
    DateTime now,
  ) {
    final policy = AutoReminderBuilder.currentPolicy(records);
    if (policy != null) {
      return (policy.validTo.difference(now).inHours / 24 / insuranceFullDays).clamp(0.0, 1.0);
    }
    for (final task in tasks) {
      if (!task.isInsurance) continue;
      final remaining = taskRemaining(task, now: now);
      if (remaining != null) return remaining;
    }
    return null;
  }
}
