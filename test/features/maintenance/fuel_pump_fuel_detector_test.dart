import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/maintenance/domain/fuel_pump_fuel_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('finds diesel even when the recognizer garbles the word', () {
    expect(FuelPumpFuelDetector.detect(['SOCAR', 'DIESEL', 'NANO']), FuelType.DIESEl);
    expect(FuelPumpFuelDetector.detect(['DIESELA', 'Encore']), FuelType.DIESEl);
    expect(FuelPumpFuelDetector.detect(['ДП', 'ULTRA']), FuelType.DIESEl);
  });

  test('finds the octane grade', () {
    expect(FuelPumpFuelDetector.detect(['A-95', 'EURO', 'SOCAR']), FuelType.Ai95);
    expect(FuelPumpFuelDetector.detect(['NANO 95', 'EURO']), FuelType.Ai95);
    expect(FuelPumpFuelDetector.detect(['А-92', 'ЕВРО']), FuelType.Ai92);
  });

  test('ignores digits that are part of other numbers', () {
    expect(FuelPumpFuelDetector.detect(['1950', '95.50', '299.95']), isNull);
  });

  test('returns null when several fuels are in the frame', () {
    expect(FuelPumpFuelDetector.detect(['92', '95', 'DIESEL']), isNull);
  });

  test('returns null when no fuel is named', () {
    expect(FuelPumpFuelDetector.detect(['SOCAR', 'Encore']), isNull);
  });
}
