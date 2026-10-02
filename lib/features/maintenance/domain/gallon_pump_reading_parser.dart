import 'package:fines_plus/features/maintenance/domain/fuel_pump_reading_parser.dart';

/// Gallons, price per gallon and total read off a US pump display. Unlike
/// [FuelPumpReadingParser] the order of the numbers isn't relied on: US
/// pumps show the total above the gallons, and the price of every grade
/// (the neighbouring ones too) is printed below, so the three numbers that
/// agree - gallons x price = total - are picked out of all of them.
class GallonPumpReadingParser {
  const GallonPumpReadingParser._();

  /// Gallons have three decimals and the price is exact, so the product is
  /// off by a rounding of the gallons and of the total at most.
  static const double _tolerance = 0.015;
  static const double _minPrice = 1.5;
  static const double _maxPrice = 8;
  static const double _maxGallons = 100;
  static const double _minTotal = 3;

  /// The reading from the first pass where three numbers add up, else from
  /// all passes pooled (each pass misses different digits). Null when none
  /// do - better to ask the user to type it than to fill in a misread digit.
  static FuelPumpReading? parsePasses(Iterable<Iterable<String>> passes) {
    for (final pass in passes) {
      final reading = _find(_numbersIn(pass));
      if (reading != null) return reading;
    }
    return _find({for (final pass in passes) ..._numbersIn(pass)});
  }

  static FuelPumpReading? _find(Set<double> numbers) {
    for (final total in numbers) {
      if (total < _minTotal) continue;
      for (final price in numbers) {
        if (price < _minPrice || price > _maxPrice) continue;
        for (final gallons in numbers) {
          if (gallons > _maxGallons || (gallons * price - total).abs() > _tolerance) continue;
          return (volume: gallons, price: price, total: total);
        }
      }
    }
    return null;
  }

  /// Recognizers don't see the small decimal point of a seven-segment
  /// display, so "21.102" often comes back as "21102": a bare run of 3+
  /// digits is offered as thousandths (gallons, price) and as hundredths
  /// (total).
  static Set<double> _numbersIn(Iterable<String> lines) {
    final numbers = <double>{};
    for (final line in lines) {
      final normalized = line.replaceAllMapped(RegExp(r'(\d)\s*[.,]\s*(\d)'), (m) => '${m[1]}.${m[2]}');
      for (final match in RegExp(r'\d+(?:\.\d{1,3})?(?!\d)').allMatches(normalized)) {
        final text = match.group(0)!;
        final value = double.tryParse(text);
        if (value == null || value <= 0) continue;
        if (text.contains('.')) {
          numbers.add(value);
        } else if (text.length >= 3) {
          numbers..add(value / 100)..add(value / 1000);
        }
      }
    }
    return numbers;
  }
}
