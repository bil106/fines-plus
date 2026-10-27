import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';

typedef MileagePoint = ({DateTime date, int mileage});

/// Computes the automatic reminders (insurance expiry, oil change) from data
/// the app already has. Pure - no I/O - so it is cheap to re-run whenever a
/// source changes.
class AutoReminderBuilder {
  static const int oilTimeHorizonDays = 30;
  static const int _speedWindowDays = 90;
  static const int _minSpeedSpanDays = 7;

  static List<ReminderItem> build({
    required List<InsuranceRecord> insurance,
    required List<MaintenanceTask> tasks,
    required int liveMileage,
    required List<MileagePoint> mileagePoints,
    required DateTime now,
  }) {
    return [
      ..._insurance(insurance, tasks, now),
      ?_oil(tasks, liveMileage, _kmPerDay(mileagePoints, now), now),
    ];
  }

  /// The policies worth a reminder, soonest end date first: every one that
  /// hasn't ended yet (a car can hold several, e.g. MTPL and casco), or just
  /// the one that ended last when all of them have, so a lapsed policy
  /// still nags. A policy renewed under the same company and number is
  /// represented only by its latest end date, not as two policies.
  static List<InsuranceRecord> trackedPolicies(List<InsuranceRecord> records, DateTime now) {
    final latest = <String, InsuranceRecord>{};
    for (final record in records) {
      final key = '${record.company.trim().toLowerCase()}|${record.policyNumber.trim().toLowerCase()}';
      final seen = latest[key];
      if (seen == null || record.validTo.isAfter(seen.validTo)) latest[key] = record;
    }
    final policies = latest.values.toList()..sort((a, b) => a.validTo.compareTo(b.validTo));

    final today = DateTime(now.year, now.month, now.day);
    final active = policies.where((p) => !p.validTo.isBefore(today)).toList();
    return active.isNotEmpty || policies.isEmpty ? active : [policies.last];
  }

  static List<ReminderItem> _insurance(List<InsuranceRecord> records, List<MaintenanceTask> tasks, DateTime now) {
    final policies = trackedPolicies(records, now);
    if (policies.isNotEmpty) {
      return [
        for (final policy in policies)
          ReminderItem(
            id: 'auto_insurance_${policy.id ?? policy.validTo.millisecondsSinceEpoch}',
            kind: ReminderKind.insurance,
            label: policy.company,
            dueDate: policy.validTo,
          ),
      ];
    }

    for (final task in tasks) {
      final last = task.lastServiceDate;
      final interval = task.intervalTime;
      if (task.isInsurance && last != null && interval != null) {
        return [ReminderItem(id: 'auto_insurance', kind: ReminderKind.insurance, dueDate: last.add(interval))];
      }
    }
    return const [];
  }

  static ReminderItem? _oil(List<MaintenanceTask> tasks, int liveMileage, double? kmPerDay, DateTime now) {
    final task = tasks.where((t) => !t.isInsurance && t.category.toLowerCase() == 'oil').firstOrNull;
    if (task == null) return null;

    int? remainingKm;
    final intervalKm = task.intervalKm;
    if (intervalKm != null) {
      final current = liveMileage > (task.actualMileage ?? 0) ? liveMileage : task.actualMileage ?? 0;
      remainingKm = intervalKm - (current - task.lastMileage);
    }

    final last = task.lastServiceDate;
    final interval = task.intervalTime;
    final dueDate = (last != null && interval != null) ? last.add(interval) : null;

    final item = ReminderItem(
      id: 'auto_oil',
      kind: ReminderKind.oil,
      dueDate: dueDate,
      remainingKm: remainingKm,
      estimatedDays: (remainingKm != null && remainingKm > 0 && kmPerDay != null)
          ? (remainingKm / kmPerDay).ceil()
          : null,
    );

    final days = item.daysLeft(now);
    final kmDue = remainingKm != null && remainingKm <= ReminderItem.soonKm;
    final dateDue = days != null && days <= oilTimeHorizonDays;
    return (kmDue || dateDue) ? item : null;
  }

  /// Average km/day over the last [_speedWindowDays] days, or null when the
  /// records don't span enough time to say anything useful.
  static double? _kmPerDay(List<MileagePoint> points, DateTime now) {
    final since = now.subtract(const Duration(days: _speedWindowDays));
    final recent = points.where((p) => p.mileage > 0 && p.date.isAfter(since)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (recent.length < 2) return null;

    final days = recent.last.date.difference(recent.first.date).inDays;
    final km = recent.last.mileage - recent.first.mileage;
    if (days < _minSpeedSpanDays || km <= 0) return null;
    return km / days;
  }
}
