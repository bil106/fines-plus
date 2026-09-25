import 'package:flutter/services.dart';

/// Money/price input: digits with an optional fractional part of up to
/// [decimalDigits] digits (e.g. `3.49`). A typed `,` becomes `.` so the value
/// always parses with `double.tryParse`; any other edit that doesn't fit is
/// rejected (the field keeps its previous value).
class DecimalInputFormatter extends TextInputFormatter {
  final int maxIntegerDigits;
  final int decimalDigits;

  const DecimalInputFormatter({this.maxIntegerDigits = 7, this.decimalDigits = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(',', '.');
    final parts = text.split('.');
    final digitsOnly = parts.every((part) => part.codeUnits.every((unit) => unit >= 48 && unit <= 57));
    final valid = parts.length <= 2 &&
        digitsOnly &&
        parts[0].length <= maxIntegerDigits &&
        (parts.length == 1 || parts[1].length <= decimalDigits);
    return valid ? newValue.copyWith(text: text) : oldValue;
  }
}
