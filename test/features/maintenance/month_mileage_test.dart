import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

({DateTime date, int mileage}) _reading(int month, int day, int mileage) =>
    (date: DateTime(2026, month, day), mileage: mileage);

void main() {
  final september = DateTime(2026, 9, 28);

  test('counts only this month, from the last reading before it', () {
    final readings = [
      _reading(7, 3, 10000),
      _reading(8, 20, 11500),
      _reading(9, 5, 11900),
      _reading(9, 26, 12600),
    ];
    // 12600 - 11500, not the whole history since July.
    expect(MileageCalculations.monthMileage(readings, september), 1100);
  });

  test('a car with no earlier records counts within the month', () {
    final readings = [_reading(9, 2, 5000), _reading(9, 20, 5800)];
    expect(MileageCalculations.monthMileage(readings, september), 800);
  });

  test('no readings this month means no distance', () {
    expect(MileageCalculations.monthMileage([_reading(8, 1, 9000)], september), 0);
  });

  test('records without a mileage are ignored', () {
    final readings = [_reading(8, 30, 20000), _reading(9, 10, 0), _reading(9, 12, 20400)];
    expect(MileageCalculations.monthMileage(readings, september), 400);
  });
}
