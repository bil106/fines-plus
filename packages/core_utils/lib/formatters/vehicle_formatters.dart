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

class VehicleNumberFormatter extends TextInputFormatter {
  static final _letterRegExp = RegExp(r'[A-Za-zА-Яа-яІіЇїЄєҐґ]');
  static final _digitRegExp = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();

   
    final raw = <String>[];
    for (final ch in upper.split('')) {
      if (_letterRegExp.hasMatch(ch) || _digitRegExp.hasMatch(ch)) {
        raw.add(ch);
      }
    }

  
    final pattern = ['L', 'L', 'D', 'D', 'D', 'D', 'L', 'L'];
    final result = <String>[];
    int inputIndex = 0;

    for (int i = 0; i < pattern.length; i++) {
      while (inputIndex < raw.length) {
        final c = raw[inputIndex++];
        if (pattern[i] == 'L' && _letterRegExp.hasMatch(c)) {
          result.add(c);
          break;
        }
        if (pattern[i] == 'D' && _digitRegExp.hasMatch(c)) {
          result.add(c);
          break;
        }
      }
    }

    final text = result.join();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static bool isValid(String value) {
    final reg = RegExp(r'^[А-ЯІЇЄҐ]{2}\d{4}[А-ЯІЇЄҐ]{2}$');
    return reg.hasMatch(value.toUpperCase());
  }
}


/// Formatter for registration number: LLLDDDDDD

class TechPassportFormatter extends TextInputFormatter {
  static final _letterRegExp = RegExp(r'[A-Za-zА-Яа-яІіЇїЄєҐґ]');
  static final _digitRegExp = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();

 
    final raw = <String>[];
    for (final ch in upper.split('')) {
      if (_letterRegExp.hasMatch(ch) || _digitRegExp.hasMatch(ch)) {
        raw.add(ch);
      }
    }

    final result = <String>[];
    int index = 0;


    int lettersAdded = 0;
    while (index < raw.length && lettersAdded < 3) {
      final c = raw[index++];
      if (_letterRegExp.hasMatch(c)) {
        result.add(c);
        lettersAdded++;
      }
    }

  
    int digitsAdded = 0;
    while (index < raw.length && digitsAdded < 6) {
      final c = raw[index++];
      if (_digitRegExp.hasMatch(c)) {
        result.add(c);
        digitsAdded++;
      }
    }

    final text = result.join();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }


  static bool isValid(String value) {
    final reg = RegExp(r'^[А-ЯІЇЄҐ]{3}\d{6}$');
    return reg.hasMatch(value.toUpperCase());
  }
}

