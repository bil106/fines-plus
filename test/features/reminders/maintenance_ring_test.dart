import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/domain/maintenance_ring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 21, 15);

  /// A schedule task serviced [daysAgo] days ago, due every [everyDays] days.
  MaintenanceTask task(String category, {int? daysAgo, int everyDays = 100, bool isInsurance = false}) => MaintenanceTask(
    description: category,
    category: category,
    lastMileage: 100000,
    lastServiceDate: daysAgo == null ? null : now.subtract(Duration(days: daysAgo)),
    intervalTime: daysAgo == null ? null : Duration(days: everyDays),
    isInsurance: isInsurance,
  );

  ReminderModel planned(DateTime date, {String? category, bool completed = false, bool isPlanned = true}) =>
      ReminderModel(
        id: date.toIso8601String() + (category ?? ''),
        title: 'work',
        description: '',
        dateTime: date,
        ownerId: 'owner',
        isPlannedService: isPlanned,
        isCompleted: completed,
        plannedCategory: category,
      );

  InsuranceRecord policy(DateTime from, DateTime to) =>
      InsuranceRecord(company: 'c', policyNumber: 'n', validFrom: from, validTo: to, cost: 0, currency: 'UAH');

  group('color', () {
    test('red up to 20%, yellow up to 50%, green above', () {
      expect(MaintenanceRing.color(0), AppColors.lightRed);
      expect(MaintenanceRing.color(0.2), AppColors.lightRed);
      expect(MaintenanceRing.color(0.21), AppColors.amber);
      expect(MaintenanceRing.color(0.5), AppColors.amber);
      expect(MaintenanceRing.color(0.51), AppColors.green);
      expect(MaintenanceRing.color(1), AppColors.green);
    });
  });

  group('plannedRemaining', () {
    test('counts the days left over a year', () {
      expect(MaintenanceRing.plannedRemaining([planned(DateTime(2026, 10, 9, 9))], now), closeTo(18 / 365, 1e-9));
      expect(MaintenanceRing.plannedRemaining([planned(DateTime(2026, 11, 20, 9))], now), closeTo(60 / 365, 1e-9));
      expect(MaintenanceRing.plannedRemaining([planned(DateTime(2027, 12, 31, 9))], now), 1);
    });

    test('empty on the day itself and once it has passed', () {
      expect(MaintenanceRing.plannedRemaining([planned(DateTime(2026, 9, 21, 9))], now), 0);
      expect(MaintenanceRing.plannedRemaining([planned(DateTime(2026, 9, 1, 9))], now), 0);
    });

    test('takes the nearest date and ignores done or non-planned reminders', () {
      final list = [
        planned(DateTime(2026, 10, 21, 9)),
        planned(DateTime(2026, 9, 26, 9)),
        planned(DateTime(2026, 9, 22, 9), completed: true),
        planned(DateTime(2026, 9, 22, 9), isPlanned: false),
      ];
      expect(MaintenanceRing.plannedRemaining(list, now), closeTo(5 / 365, 1e-9));
      expect(MaintenanceRing.plannedRemaining(const [], now), isNull);
    });

    test('each sheet sees only its own planned services', () {
      final list = [
        planned(DateTime(2026, 9, 24, 9), category: 'Tuning'),
        planned(DateTime(2026, 10, 21, 9)), // main ТО sheet
        planned(DateTime(2027, 12, 21, 9), category: 'Oil'),
      ];
      expect(MaintenanceRing.plannedRemaining(list, now), closeTo(30 / 365, 1e-9));
      expect(MaintenanceRing.plannedRemaining(list, now, category: 'Tuning'), closeTo(3 / 365, 1e-9));
      expect(MaintenanceRing.plannedRemaining(list, now, category: 'oil'), 1);
      expect(MaintenanceRing.plannedRemaining(list, now, category: 'Tires'), isNull);
    });
  });

  group('insuranceRemaining', () {
    final today = DateTime(2026, 7, 1);

    test('days left out of a full year, whatever the policy term', () {
      final halfYear = [policy(DateTime(2026, 1, 1), DateTime(2027, 1, 1))]; // 184 days left
      expect(MaintenanceRing.insuranceRemaining(halfYear, const [], today), closeTo(184 / 365, 1e-3));
      final shortTerm = [policy(DateTime(2026, 6, 1), DateTime(2026, 8, 1))]; // 31 days left
      expect(MaintenanceRing.insuranceRemaining(shortTerm, const [], today), closeTo(31 / 365, 1e-3));
    });

    test('a year or more left is a full ring', () {
      final records = [policy(DateTime(2026, 7, 1), DateTime(2028, 7, 1))];
      expect(MaintenanceRing.insuranceRemaining(records, const [], today), 1);
    });

    test('0 once expired', () {
      final records = [policy(DateTime(2025, 1, 1), DateTime(2026, 1, 1))];
      expect(MaintenanceRing.insuranceRemaining(records, const [], today), 0);
    });

    test('null without a policy or insurance task', () {
      expect(MaintenanceRing.insuranceRemaining(const [], [task('oil', daysAgo: 1)], today), isNull);
    });

    test('falls back to an insurance schedule task', () {
      final tasks = [task('insurance', daysAgo: 50, isInsurance: true)];
      expect(MaintenanceRing.insuranceRemaining(const [], tasks, now), closeTo(0.5, 1e-9));
    });
  });
}
