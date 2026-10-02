import 'package:fines_plus/features/maintenance/domain/fuel_pump_reading_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a SOCAR pump display', () {
    final reading = FuelPumpReadingParser.parse(['SOCAR', 'LITRES', '10.50', 'CENA / LTR', 'PRICE / LTR', '54.99', 'UAH', 'TOTAL (грн)', '577.40', 'A-95', 'EURO']);
    expect(reading, (volume: 10.5, price: 54.99, total: 577.4));
  });

  test('reads other fills, ignoring octane and station text', () {
    expect(FuelPumpReadingParser.parse(['22.80', '58.50', '1333.80', 'NANO 95']), (volume: 22.8, price: 58.5, total: 1333.8));
    expect(FuelPumpReadingParser.parse(['35.60', '56.00', '1993.60', 'DIESEL']), (volume: 35.6, price: 56.0, total: 1993.6));
  });

  test('accepts a comma or a stray space as the decimal separator', () {
    expect(FuelPumpReadingParser.parse(['10,50', '54 .99', '577,40']), (volume: 10.5, price: 54.99, total: 577.4));
  });

  test('returns null when the numbers do not add up', () {
    expect(FuelPumpReadingParser.parse(['10.50', '54.99', '577.90']), isNull);
    expect(FuelPumpReadingParser.parse(['A-95', 'SOCAR']), isNull);
  });

  test('reads numbers whose decimal point the recognizer missed', () {
    expect(FuelPumpReadingParser.parse(['3560', '5600', '199360']), (volume: 35.6, price: 56.0, total: 1993.6));
  });

  test('pools numbers from several passes when no single pass has all three', () {
    final reading = FuelPumpReadingParser.parsePasses([
      ['SOCAR', '3560', 'DIESEL'],
      ['LITRES', '5600', '19935'],
      ['TOTAL', '199360'],
    ]);
    expect(reading, (volume: 35.6, price: 56.0, total: 1993.6));
  });

  test('a pass that reads everything wins over pooling', () {
    expect(
      FuelPumpReadingParser.parsePasses([
        ['10.50', '54.99', '577.40'],
        ['35.60'],
      ]),
      (volume: 10.5, price: 54.99, total: 577.4),
    );
  });

  test('pooled passes with nothing adding up give null', () {
    expect(FuelPumpReadingParser.parsePasses([['A-95'], ['550'], ['19935']]), isNull);
  });

  test('takes the product when the recognizer dropped the total\'s leading digit', () {
    expect(FuelPumpReadingParser.parse(['2280', '5850', '33380']), (volume: 22.8, price: 58.5, total: 1333.8));
  });

  test('pools passes and recovers a total missing its leading digit', () {
    final reading = FuelPumpReadingParser.parsePasses([
      ['585u', '33380'],
      ['2280', 'x', '3338'],
      ['5850'],
    ]);
    expect(reading, (volume: 22.8, price: 58.5, total: 1333.8));
  });

  test('does not accept a total that only loosely resembles the product', () {
    expect(FuelPumpReadingParser.parse(['2280', '5850', '33390']), isNull);
  });

  test('derives the price when litres and total read cleanly', () {
    final reading = FuelPumpReadingParser.parsePasses([
      ['3560', '199360'],
      ['3560', 'S60u', '199360'],
      ['3550', 'S600', '199360'],
    ]);
    expect(reading, (volume: 35.6, price: 56.0, total: 1993.6));
  });

  test('derives the litres when price and total read cleanly', () {
    final reading = FuelPumpReadingParser.parsePasses([
      ['1059', '5499', '57740'],
    ]);
    expect(reading, (volume: 10.5, price: 54.99, total: 577.4));
  });

  test('derives nothing from a total with no sane partner', () {
    expect(FuelPumpReadingParser.parsePasses([['550uw', '199360']]), isNull);
  });
}
