import 'package:fines_plus/core/extensions/fuel_calculator.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FuelRecord fill(FuelType type, double volume, int mileage, {bool full = true}) => FuelRecord(
    fuelType: type.name,
    volume: volume,
    cost: 0,
    date: DateTime(2026, 9, 1).add(Duration(days: mileage ~/ 100)),
    mileage: mileage,
    currency: 'UAH',
    fullTank: full,
  );

  group('calculateAverageFuelConsumptionAsync', () {
    test('full tank to full tank in liters per 100 km', () async {
      final records = [fill(FuelType.Ai95, 40, 1000), fill(FuelType.Ai95, 10, 1200)];
      expect(await calculateAverageFuelConsumptionAsync(records), closeTo(5, 1e-9));
    });

    test('electric charges are not counted as liters', () async {
      final records = [
        fill(FuelType.Ai95, 40, 1000),
        fill(FuelType.Electric, 30, 1100),
        fill(FuelType.Ai95, 10, 1200),
      ];
      expect(await calculateAverageFuelConsumptionAsync(records), closeTo(5, 1e-9));
    });

    test('an electric-only car has no l/100km', () async {
      final records = [fill(FuelType.Electric, 30, 1000), fill(FuelType.Electric, 30, 1200)];
      expect(await calculateAverageFuelConsumptionAsync(records), 0);
    });
  });

  group('fuelTypeFromName', () {
    test('resolves stored names, including Electric, and rejects unknown ones', () {
      expect(fuelTypeFromName('Electric'), FuelType.Electric);
      expect(fuelTypeFromName('Ai95'), FuelType.Ai95);
      expect(fuelTypeFromName('fuel'), isNull);
      expect(FuelType.Electric.isElectric, isTrue);
      expect(FuelType.Ai95.isElectric, isFalse);
    });
  });
}
