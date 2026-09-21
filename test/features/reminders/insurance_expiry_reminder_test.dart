import 'package:fines_plus/features/reminders/domain/insurance_expiry_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 21, 15);

  group('InsuranceExpiryReminder.fireAt', () {
    test('two weeks before the end date at 09:00', () {
      expect(
        InsuranceExpiryReminder.fireAt(DateTime(2026, 10, 22), now),
        DateTime(2026, 10, 8, 9),
      );
    });

    test('follows the end date when it changes', () {
      final before = InsuranceExpiryReminder.fireAt(
        DateTime(2026, 10, 30),
        now,
      );
      final after = InsuranceExpiryReminder.fireAt(DateTime(2026, 10, 22), now);
      expect(before, DateTime(2026, 10, 16, 9));
      expect(after, DateTime(2026, 10, 8, 9));
    });

    test('already inside the last two weeks: next 09:00', () {
      expect(
        InsuranceExpiryReminder.fireAt(DateTime(2026, 10, 1), now),
        DateTime(2026, 9, 22, 9),
      );
      expect(
        InsuranceExpiryReminder.fireAt(
          DateTime(2026, 9, 21),
          DateTime(2026, 9, 21, 8),
        ),
        DateTime(2026, 9, 21, 9),
      );
    });

    test('nothing once the policy has expired, or no time is left today', () {
      expect(
        InsuranceExpiryReminder.fireAt(DateTime(2026, 9, 20), now),
        isNull,
      );
      expect(
        InsuranceExpiryReminder.fireAt(DateTime(2026, 9, 21), now),
        isNull,
      );
    });
  });
}
