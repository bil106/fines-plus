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

  test('prefers values at or above the last known mileage', () {
    expect(OdometerReadingParser.parse(['98765', '132150'], lastKnown: 132000), 132150);
    expect(OdometerReadingParser.parse(['TRIP 99999', '132150'], lastKnown: 132150), 132150);
  });

  test('still offers a reading below the last known mileage when nothing else fits', () {
    expect(OdometerReadingParser.parse(['mi', '87256', '362.4'], lastKnown: 132150), 87256);
    expect(OdometerReadingParser.parse(['Distance to Empty', '342mi', 'ODO', '52876mi'], lastKnown: 132150), 52876);
    expect(OdometerReadingParser.parse(['12:34', 'km', '65432', 'trip', '124.6'], lastKnown: 132150), 65432);
  });

  test('returns null without digits or above the field limit', () {
    expect(OdometerReadingParser.parse(['no numbers here']), isNull);
    expect(OdometerReadingParser.parse(['12345678']), isNull);
  });
}
