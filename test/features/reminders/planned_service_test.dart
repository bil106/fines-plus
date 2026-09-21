import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/domain/planned_service.dart';
import 'package:flutter_test/flutter_test.dart';

ReminderModel _reminder(
  DateTime date, {
  bool planned = true,
  bool completed = false,
}) => ReminderModel(
  id: date.toIso8601String(),
  title: 'Oil',
  description: '',
  dateTime: date,
  ownerId: 'owner',
  isPlannedService: planned,
  isCompleted: completed,
);

void main() {
  final now = DateTime(2026, 9, 21, 15);

  group('PlannedService.isPlannedDate', () {
    test('only a date after today means planned', () {
      expect(PlannedService.isPlannedDate(DateTime(2026, 9, 22), now), isTrue);
      expect(PlannedService.isPlannedDate(DateTime(2026, 9, 21), now), isFalse);
      expect(PlannedService.isPlannedDate(DateTime(2026, 9, 20), now), isFalse);
    });
  });

  group('PlannedService.status', () {
    test('no planned services', () {
      expect(PlannedService.status([], now), PlannedStatus.none);
      expect(
        PlannedService.status([
          _reminder(DateTime(2026, 9, 25), planned: false),
        ], now),
        PlannedStatus.none,
      );
    });

    test('future date is upcoming, today included', () {
      expect(
        PlannedService.status([_reminder(DateTime(2026, 9, 25, 9))], now),
        PlannedStatus.upcoming,
      );
      expect(
        PlannedService.status([_reminder(DateTime(2026, 9, 21, 9))], now),
        PlannedStatus.upcoming,
      );
    });

    test('past date is overdue and beats an upcoming one', () {
      final list = [
        _reminder(DateTime(2026, 9, 25, 9)),
        _reminder(DateTime(2026, 9, 20, 9)),
      ];
      expect(PlannedService.status(list, now), PlannedStatus.overdue);
    });

    test('each sheet only sees its own planned services', () {
      final list = [_reminder(DateTime(2026, 9, 20, 9)).copyWith(plannedCategory: 'Oil')];
      expect(PlannedService.status(list, now), PlannedStatus.none);
      expect(PlannedService.status(list, now, category: 'Oil'), PlannedStatus.overdue);
      expect(PlannedService.status(list, now, category: 'Tires'), PlannedStatus.none);
    });

    test('completed ones are ignored', () {
      expect(
        PlannedService.status([
          _reminder(DateTime(2026, 9, 20, 9), completed: true),
        ], now),
        PlannedStatus.none,
      );
    });
  });
}
