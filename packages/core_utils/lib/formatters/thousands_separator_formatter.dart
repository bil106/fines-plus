import 'package:flutter/services.dart';

/// Groups digits with a space every 3 (from the right) as the user types,
/// e.g. "128450" -> "128 450" - matches the mockup's odometer/mileage
/// display. Expects to run after any digits-only filtering in the
/// formatter chain, since it treats every non-space character as a digit.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(' ', '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      final positionFromEnd = digitsOnly.length - i;
      buffer.write(digitsOnly[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) buffer.write(' ');
    }
    final formatted = buffer.toString();

    final cursorOffsetFromEnd = newValue.text.length - newValue.selection.end;
    final newOffset = (formatted.length - cursorOffsetFromEnd).clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

/// Strips the spaces [ThousandsSeparatorInputFormatter] inserts, so the
/// raw digit string can be parsed back into a number.
String stripThousandsSeparator(String text) => text.replaceAll(' ', '');

/// Formats [value] the same way [ThousandsSeparatorInputFormatter] would as
/// the user types it - for prefilling a field with an already-known number.
String formatThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final positionFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) buffer.write(' ');
  }
  return buffer.toString();
}
