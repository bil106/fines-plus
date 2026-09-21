import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:fines_plus/features/reminders/domain/auto_reminder_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 19);

  InsuranceRecord policy(DateTime validTo, {DateTime? updatedAt}) => InsuranceRecord(
    company: 'c',
    policyNumber: 'n',
    validFrom: validTo.subtract(const Duration(days: 365)),
    validTo: validTo,
    cost: 0,
    currency: 'UAH',
    updatedAt: updatedAt,
  );

  MaintenanceTask oil({int? intervalKm, int lastMileage = 100000, int? actual, DateTime? last, Duration? interval}) =>
      MaintenanceTask(
        description: 'Oil',
        category: 'oil',
        lastMileage: lastMileage,
        actualMileage: actual,
        intervalKm: intervalKm,
        lastServiceDate: last,
        intervalTime: interval,
      );

  List<ReminderItem> build({
    List<InsuranceRecord> insurance = const [],
    List<MaintenanceTask> tasks = const [],
    int mileage = 0,
    List<MileagePoint> points = const [],
  }) => AutoReminderBuilder.build(
    insurance: insurance,
    tasks: tasks,
    liveMileage: mileage,
    mileagePoints: points,
    now: now,
  );

  group('insurance', () {
    test('nothing without data', () => expect(build(), isEmpty));

    test('uses the policy saved last, even if it ends sooner', () {
      final items = build(
        insurance: [
          policy(DateTime(2027, 10, 12), updatedAt: DateTime(2026, 9, 1)),
          policy(DateTime(2026, 10, 12), updatedAt: DateTime(2026, 9, 18)),
        ],
      );
      expect(items.single.dueDate, DateTime(2026, 10, 12));
    });

    test('without save times, the later policy wins', () {
      final items = build(insurance: [policy(DateTime(2026, 10, 12)), policy(DateTime(2027, 10, 12))]);
      expect(items.single.dueDate, DateTime(2027, 10, 12));
    });

    test('status thresholds', () {
      ReminderStatus status(DateTime end) => build(insurance: [policy(end)]).single.status(now);
      expect(status(DateTime(2026, 9, 18)), ReminderStatus.overdue);
      expect(status(DateTime(2026, 9, 19)), ReminderStatus.soon);
      expect(status(DateTime(2026, 10, 3)), ReminderStatus.soon);
      expect(status(DateTime(2026, 10, 4)), ReminderStatus.upcoming);
    });

    test('falls back to the insurance task interval', () {
      final task = MaintenanceTask(
        description: 'Insurance',
        category: 'insurance',
        isInsurance: true,
        lastMileage: 0,
        lastServiceDate: DateTime(2025, 12, 1),
        intervalTime: const Duration(days: 365),
      );
      expect(build(tasks: [task]).single.dueDate, DateTime(2026, 12, 1));
    });
  });

  group('oil', () {
    test('hidden while far from due', () {
      expect(build(tasks: [oil(intervalKm: 10000)], mileage: 102000), isEmpty);
    });

    test('shown as soon at 500 km left', () {
      final item = build(tasks: [oil(intervalKm: 10000)], mileage: 109500).single;
      expect(item.remainingKm, 500);
      expect(item.status(now), ReminderStatus.soon);
    });

    test('overdue once the interval is exceeded', () {
      final item = build(tasks: [oil(intervalKm: 10000)], mileage: 110200).single;
      expect(item.status(now), ReminderStatus.overdue);
    });

    test('estimates days from recent driving speed', () {
      final item = build(
        tasks: [oil(intervalKm: 10000)],
        mileage: 109500,
        points: [
          (date: DateTime(2026, 8, 19), mileage: 108000),
          (date: DateTime(2026, 9, 18), mileage: 109500),
        ],
      ).single;
      expect(item.estimatedDays, 10);
    });

    test('no estimate when records span too little time', () {
      final item = build(
        tasks: [oil(intervalKm: 10000)],
        mileage: 109500,
        points: [(date: DateTime(2026, 9, 17), mileage: 109000), (date: DateTime(2026, 9, 18), mileage: 109500)],
      ).single;
      expect(item.estimatedDays, isNull);
    });

    test('shown by date when the time interval is nearly up', () {
      final items = build(tasks: [oil(last: DateTime(2025, 10, 1), interval: const Duration(days: 365))]);
      expect(items.single.dueDate, DateTime(2026, 10, 1));
    });
  });
}
