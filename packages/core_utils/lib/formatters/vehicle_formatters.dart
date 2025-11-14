// packages/core_utils/lib/formatters/vehicle_formatters.dart
import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/services.dart';

class VehicleFormatters {
  static final _months = [
    S.current.month_jan,
    S.current.month_feb,
    S.current.month_mar,
    S.current.month_apr,
    S.current.month_may,
    S.current.month_jun,
    S.current.month_jul,
    S.current.month_aug,
    S.current.month_sep,
    S.current.month_oct,
    S.current.month_nov,
    S.current.month_dec
  ];

  /// Formats month and year as "Veres 2025"
  static String formatMonthYear(DateTime date) {
    final month = _months[date.month - 1];
    final year = date.year;
    return "$month $year";
  }
}

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

/// Formatter for registration number: LLLDDDDD (3 letters + 6 digits)
class TechPassportFormatter extends TextInputFormatter {
  static final _letterRegExp = RegExp(r'[A-Za-zА-Яа-яІіЇїЄєҐґ]');
  static final _digitRegExp = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase();

    // filtering letters and digits
    final raw = <String>[];
    for (final ch in text.split('')) {
      if (_letterRegExp.hasMatch(ch) || _digitRegExp.hasMatch(ch)) {
        raw.add(ch);
      }
    }

    final result = StringBuffer();
    int index = 0;

    // 3 letters
    int lettersAdded = 0;
    while (index < raw.length && lettersAdded < 3) {
      if (_letterRegExp.hasMatch(raw[index])) {
        result.write(raw[index]);
        lettersAdded++;
      }
      index++;
    }

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
    final reg = RegExp(r'^[A-Za-zА-ЯІЇЄҐ]{3}\d{6}$');
    return reg.hasMatch(value.toUpperCase());
  }
}
