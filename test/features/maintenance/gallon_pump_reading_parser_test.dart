import 'package:fines_plus/features/maintenance/domain/gallon_pump_reading_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a pump showing the neighbouring grades\' prices too', () {
    final reading = GallonPumpReadingParser.parsePasses([
      ['\$', '91.77', 'Sale', '21.102', 'Gallons', '4.349', 'EC Unleaded', '4.439', '4.539', '87', '89', '91'],
    ]);
    expect(reading, (volume: 21.102, price: 4.349, total: 91.77));
  });

  test('reads a total above gallons with a price of another grade', () {
    final reading = GallonPumpReadingParser.parsePasses([
      ['Purchase \$', '51.48', 'Gallons', '10.299', '4.799', '4.999', '5.099'],
    ]);
    expect(reading, (volume: 10.299, price: 4.999, total: 51.48));
  });

  test('reads numbers whose decimal point the recognizer missed', () {
    final reading = GallonPumpReadingParser.parsePasses([
      ['8701', '20429', '4359', '4459', '4259'],
    ]);
    expect(reading, (volume: 20.429, price: 4.259, total: 87.01));
  });

  test('pools numbers from several passes', () {
    final reading = GallonPumpReadingParser.parsePasses([
      ['8701', 'Sale'],
      ['20429', 'Gallons'],
      ['4259'],
    ]);
    expect(reading, (volume: 20.429, price: 4.259, total: 87.01));
  });

  test('returns null when the numbers do not add up', () {
    expect(GallonPumpReadingParser.parsePasses([['87.01', '20.429', '4.559']]), isNull);
    expect(GallonPumpReadingParser.parsePasses([['Regular', '87']]), isNull);
  });
}
