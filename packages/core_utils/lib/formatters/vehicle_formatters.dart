// packages/core_utils/lib/formatters/vehicle_formatters.dart
import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/plate_market.dart';
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

/// Car plate input for the brand's [PlateMarket]: keeps only characters
/// that fit the market's pattern, uppercased and without spaces/dashes.
class VehicleNumberFormatter extends TextInputFormatter {
  final PlateMarket market;

  VehicleNumberFormatter({this.market = PlateMarket.ua});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase().split('').where(market.isAlphanumeric).toList();

    final slots = market.slots;
    final result = <String>[];
    if (slots == null) {
      result.addAll(raw.take(market.maxLength));
    } else {
      int inputIndex = 0;
      for (int i = 0; i < slots.length; i++) {
        while (inputIndex < raw.length) {
          final c = raw[inputIndex++];
          if (slots[i] == 'L' ? market.isLetter(c) : market.isDigit(c)) {
            result.add(c);
            break;
          }
        }
      }
    }

    final text = result.join();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}


/// Formatter for registration number: LLLDDDDDD

class TechPassportFormatter extends TextInputFormatter {
  static final _letterRegExp = RegExp(r'[A-Za-z]');
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
    if (value.isEmpty) return true;
    final reg = RegExp(r'^[A-Z]{3}\d{6}$');
    return reg.hasMatch(value.toUpperCase());
  }
}

