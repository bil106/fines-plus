import 'package:core_utils/formatters/plate_market.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

String _format(PlateMarket market, String input) => VehicleNumberFormatter(market: market)
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: input))
    .text;

void main() {
  group('PlateMarket.fromCode', () {
    test('maps known markets and falls back to free-form', () {
      expect(PlateMarket.fromCode('UA'), PlateMarket.ua);
      expect(PlateMarket.fromCode('es'), PlateMarket.es);
      expect(PlateMarket.fromCode('US'), PlateMarket.us);
      expect(PlateMarket.fromCode('GB'), PlateMarket.us);
    });
  });

  group('isValid', () {
    test('UA keeps the strict AA1234BB pattern', () {
      expect(PlateMarket.ua.isValid('KA7777AB'), isTrue);
      expect(PlateMarket.ua.isValid('1234BCD'), isFalse);
    });

    test('ES accepts 4 digits + 3 consonants only', () {
      expect(PlateMarket.es.isValid('1234BCD'), isTrue);
      expect(PlateMarket.es.isValid('1234ABC'), isFalse);
      expect(PlateMarket.es.isValid('KA7777AB'), isFalse);
    });

    test('US accepts 1-8 letters/digits', () {
      expect(PlateMarket.us.isValid('8ABC123'), isTrue);
      expect(PlateMarket.us.isValid('GOUCLA'), isTrue);
      expect(PlateMarket.us.isValid(''), isFalse);
      expect(PlateMarket.us.isValid('ABCDE12345'), isFalse);
    });
  });

  group('display', () {
    test('spaces standard plates, leaves the rest as typed', () {
      expect(PlateMarket.ua.display('aa1234bb'), 'AA 1234 BB');
      expect(PlateMarket.es.display('1234bcd'), '1234 BCD');
      expect(PlateMarket.us.display('8abc123'), '8ABC123');
      expect(PlateMarket.ua.display('custom1'), 'CUSTOM1');
    });
  });

  group('VehicleNumberFormatter', () {
    test('UA drops characters that do not fit the pattern', () {
      expect(_format(PlateMarket.ua, 'ka 7777 ab'), 'KA7777AB');
    });

    test('ES skips vowels in the letter part', () {
      expect(_format(PlateMarket.es, '1234 abcd'), '1234BCD');
    });

    test('US keeps letters/digits, drops dashes, caps at 8', () {
      expect(_format(PlateMarket.us, 'abc-1234'), 'ABC1234');
      expect(_format(PlateMarket.us, 'abcdefghij'), 'ABCDEFGH');
    });
  });
}
