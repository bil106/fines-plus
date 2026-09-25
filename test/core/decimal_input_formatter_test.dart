import 'package:core_utils/formatters/decimal_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

String _type(String previous, String next, {int maxIntegerDigits = 7}) =>
    DecimalInputFormatter(maxIntegerDigits: maxIntegerDigits)
        .formatEditUpdate(
          TextEditingValue(text: previous),
          TextEditingValue(text: next),
        )
        .text;

void main() {
  test('accepts cents and turns a typed comma into a dot', () {
    expect(_type('3', '3.4'), '3.4');
    expect(_type('3.4', '3.49'), '3.49');
    expect(_type('3', '3,'), '3.');
    expect(_type('3,4', '3,49'), '3.49');
  });

  test('rejects a third decimal, a second separator and letters', () {
    expect(_type('3.49', '3.499'), '3.49');
    expect(_type('3.4', '3.4.'), '3.4');
    expect(_type('3', '3a'), '3');
  });

  test('limits the integer part', () {
    expect(_type('999', '9999', maxIntegerDigits: 3), '999');
    expect(_type('', '1234567'), '1234567');
    expect(_type('1234567', '12345678'), '1234567');
  });

  test('allows clearing the field', () {
    expect(_type('3.49', ''), '');
  });
}
