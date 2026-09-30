import 'package:fines_plus/features/maintenance/domain/odometer_reading_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a plain odometer number', () {
    expect(OdometerReadingParser.parse(['132150']), 132150);
  });

  test('joins thousands groups', () {
    expect(OdometerReadingParser.parse(['132 150 km']), 132150);
    expect(OdometerReadingParser.parse(['132,150']), 132150);
  });

  test('prefers the odometer over trip meter, clock and temperature', () {
    expect(OdometerReadingParser.parse(['14:35', '21', 'TRIP 512.4', '132150']), 132150);
  });

  test('drops values below the last known mileage', () {
    expect(OdometerReadingParser.parse(['98765', '132150'], lastKnown: 132000), 132150);
    expect(OdometerReadingParser.parse(['512'], lastKnown: 132000), isNull);
  });

  test('returns null without digits or above the field limit', () {
    expect(OdometerReadingParser.parse(['no numbers here']), isNull);
    expect(OdometerReadingParser.parse(['12345678']), isNull);
  });
}
