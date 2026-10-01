/// Litres, price per litre and total read off a fuel pump's display.
typedef FuelPumpReading = ({double litres, double price, double total});

/// Picks litres / price / total out of the text lines recognised on a photo
/// of a pump display. The pump shows them top to bottom in that order, and
/// the total is always litres x price, which is what tells them apart from
/// the other numbers in the frame (octane "95", station signs, prices of
/// neighbouring pumps).
class FuelPumpReadingParser {
  const FuelPumpReadingParser._();

  /// Pumps round the total to cents.
  static const double _tolerance = 0.02;

  /// The reading from one recognition pass, or null when no three numbers on
  /// the photo add up - better to ask the user to type it than to fill in a
  /// misread digit.
  static FuelPumpReading? parse(Iterable<String> lines) {
    final numbers = _numbersIn(lines);
    for (final matches in [_adds, _addsLosingLeadingDigit]) {
      for (var i = 0; i < numbers.length; i++) {
        for (var j = i + 1; j < numbers.length; j++) {
          for (var k = j + 1; k < numbers.length; k++) {
            if (matches(numbers[i], numbers[j], numbers[k])) {
              return (litres: numbers[i], price: numbers[j], total: _product(numbers[i], numbers[j]));
            }
          }
        }
      }
    }
    return null;
  }

  /// Several passes over the same photo (as taken, contrast-boosted, ...)
  /// each miss different digits. A pass that reads everything on its own wins;
  /// otherwise the numbers from all passes are pooled. Across passes the order
  /// on the display is lost, so the price is taken to be the larger of the two
  /// factors - a fill-up is usually fewer litres than a litre costs in hryvnias.
  /// Failing that, a missing litres or price is derived, see [_deriveMissingFactor].
  static FuelPumpReading? parsePasses(Iterable<Iterable<String>> passes) {
    for (final pass in passes) {
      final reading = parse(pass);
      if (reading != null) return reading;
    }
    final pool = {for (final pass in passes) ..._numbersIn(pass)}.toList();
    for (final matches in [_adds, _addsLosingLeadingDigit]) {
      for (var i = 0; i < pool.length; i++) {
        for (var j = i + 1; j < pool.length; j++) {
          for (final total in pool) {
            if (total == pool[i] || total == pool[j] || !matches(pool[i], pool[j], total)) continue;
            final litres = pool[i] < pool[j] ? pool[i] : pool[j];
            final price = pool[i] < pool[j] ? pool[j] : pool[i];
            return (litres: litres, price: price, total: _product(litres, price));
          }
        }
      }
    }
    return _deriveMissingFactor(pool);
  }

  static const double _minPrice = 20;
  static const double _maxPrice = 150;
  static const double _maxLitres = 150;
  static const double _minTotal = 100;

  /// Last resort when no three numbers agree: the total and one factor read
  /// cleanly (the price is the digit a recognizer garbles most often) and the
  /// other factor is derived from them. Only sane pump values count, and the
  /// derived factor must reproduce the total to the cent, so a stray number
  /// rarely passes. The total is the one actually read.
  static FuelPumpReading? _deriveMissingFactor(List<double> pool) {
    for (final total in pool) {
      if (total < _minTotal) continue;
      for (final known in pool) {
        if (known == total || known > total) continue;
        final derived = (total / known * 100).round() / 100;
        if (!_adds(known, derived, total)) continue;
        final knownIsPrice = known >= _minPrice && known <= _maxPrice && derived >= 1 && derived <= _maxLitres;
        final knownIsLitres = known >= 1 && known <= _maxLitres && derived >= _minPrice && derived <= _maxPrice;
        if (!knownIsPrice && !knownIsLitres) continue;
        final litres = known < derived ? known : derived;
        final price = known < derived ? derived : known;
        return (litres: litres, price: price, total: total);
      }
    }
    return null;
  }

  static double _product(double litres, double price) => (litres * price * 100).round() / 100;

  static bool _adds(double litres, double price, double total) => (litres * price - total).abs() <= _tolerance;

  /// A thin "1" is often the one digit a recognizer drops from a display, so
  /// "1333.80" arrives as "333.80". The total counts as read when it is the
  /// product minus exactly one leading digit, with five or more digits left to
  /// match - the product is then the real total.
  static bool _addsLosingLeadingDigit(double litres, double price, double total) {
    final expected = (_product(litres, price) * 100).round().toString();
    final read = (total * 100).round().toString();
    return read.length >= 5 && expected.length == read.length + 1 && expected.endsWith(read);
  }

  /// Recognizers don't see the small decimal point of a seven-segment display,
  /// so "35.60" often comes back as "3560": a bare run of 3+ digits is offered
  /// both as it is and as hundredths.
  static List<double> _numbersIn(Iterable<String> lines) {
    final numbers = <double>[];
    for (final line in lines) {
      // "577 .40" / "577,40": the recognizer may add a space or use a comma.
      final normalized = line.replaceAllMapped(RegExp(r'(\d)\s*[.,]\s*(\d)'), (m) => '${m[1]}.${m[2]}');
      for (final match in RegExp(r'\d+(?:\.\d{1,2})?(?!\d)').allMatches(normalized)) {
        final text = match.group(0)!;
        final value = double.tryParse(text);
        if (value == null || value <= 0) continue;
        if (text.contains('.')) {
          numbers.add(value);
        } else if (text.length >= 3) {
          numbers.add(value / 100);
        }
      }
    }
    return numbers;
  }
}
