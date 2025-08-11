// packages/core_utils/lib/formatters/vehicle_formatters.dart
import 'package:flutter/services.dart';

/// Formatter for car number: LLDDDDLL (L — letter, D — number)
class VehicleNumberFormatter extends TextInputFormatter {
  final bool mapLatinToCyrillic;

  VehicleNumberFormatter({this.mapLatinToCyrillic = true});

  static final _letterRegExp = RegExp(r'[A-Za-zА-Яа-яІіЇїЄєҐґ]');
  static final _digitRegExp = RegExp(r'\d');

  static const Map<String, String> _latinToCyr = {
    'A': 'А',
    'B': 'В',
    'E': 'Е',
    'K': 'К',
    'M': 'М',
    'H': 'Н',
    'O': 'О',
    'P': 'Р',
    'C': 'С',
    'T': 'Т',
    'Y': 'У',
    'X': 'Х',
  };

  String _mapLetter(String ch) => mapLatinToCyrillic ? (_latinToCyr[ch] ?? ch) : ch;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();

   // filtering
    final raw = <String>[];
    for (final ch in upper.split('')) {
      if (_letterRegExp.hasMatch(ch)) {
        raw.add(_mapLetter(ch));
      } else if (_digitRegExp.hasMatch(ch)) {
        raw.add(ch);
      }
    }

    // pattern: L L D D D D L L
    final pattern = ['L', 'L', 'D', 'D', 'D', 'D', 'L', 'L'];
    final resultChars = <String>[];
    int inputIndex = 0;

    for (int i = 0; i < pattern.length; i++) {
      bool filled = false;
      while (inputIndex < raw.length) {
        final c = raw[inputIndex++];
        if (pattern[i] == 'L' && _letterRegExp.hasMatch(c)) {
          resultChars.add(c);
          filled = true;
          break;
        } else if (pattern[i] == 'D' && _digitRegExp.hasMatch(c)) {
          resultChars.add(c);
          filled = true;
          break;
        }
      }
      if (!filled) break;
    }

    final result = resultChars.join();

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

/// Validator for car number
  static bool isValid(String value) {
    final reg = RegExp(r'^[A-Za-zА-ЯІЇЄҐ]{2}\d{4}[A-Za-zА-ЯІЇЄҐ]{2}$');
    return reg.hasMatch(value.toUpperCase());
  }
}

/// Formatter for registration number: LL DDDDDD
class TechPassportFormatter extends TextInputFormatter {
  final bool mapLatinToCyrillic;

  TechPassportFormatter({this.mapLatinToCyrillic = true});

  static final _letterRegExp = VehicleNumberFormatter._letterRegExp;
  static final _digitRegExp = VehicleNumberFormatter._digitRegExp;
  static final _latinToCyr = VehicleNumberFormatter._latinToCyr;

  String _mapLetter(String ch) => mapLatinToCyrillic ? (_latinToCyr[ch] ?? ch) : ch;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase();

    // filtering
    final raw = <String>[];
    for (final ch in text.split('')) {
      if (_letterRegExp.hasMatch(ch)) {
        raw.add(_mapLetter(ch));
      } else if (_digitRegExp.hasMatch(ch)) {
        raw.add(ch);
      }
    }

    final result = StringBuffer();
    int index = 0;

    // 2 letters
    for (int i = 0; i < 2 && index < raw.length; i++) {
      if (_letterRegExp.hasMatch(raw[index])) {
        result.write(raw[index]);
        index++;
      } else {
        raw.removeAt(index);
        i--;
      }
    }

    if (result.isNotEmpty) result.write(' ');

   // 6 digits
    int digitsAdded = 0;
    while (index < raw.length && digitsAdded < 6) {
      if (_digitRegExp.hasMatch(raw[index])) {
        result.write(raw[index]);
        digitsAdded++;
      }
      index++;
    }

    final formatted = result.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Validator for registration certificate
  static bool isValid(String value) {
    final reg = RegExp(r'^[A-Za-zА-ЯІЇЄҐ]{2} \d{6}$');
    return reg.hasMatch(value.toUpperCase());
  }
}
