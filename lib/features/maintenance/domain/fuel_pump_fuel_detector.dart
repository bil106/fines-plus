import 'package:fines_plus/core/extensions/fuel_type.dart';

/// Tells which fuel a pump photo is of from the grade label recognised on it
/// ("DIESEL", "A-95", "NANO 95", ...).
class FuelPumpFuelDetector {
  const FuelPumpFuelDetector._();

  // Recognizers garble letters ("DIESELA", "DIESEI"), so only a stem is matched.
  static final Map<FuelType, RegExp> _labels = {
    FuelType.DIESEl: RegExp(r'DIES|ДИЗ|(?<![А-ЯІЇЄA-Z])Д[ПТ](?![А-ЯІЇЄA-Z])', caseSensitive: false),
    FuelType.LPG: RegExp(r'LPG|АВТОГАЗ|ПРОПАН', caseSensitive: false),
    FuelType.Ai98: RegExp(r'(?<![\d.,])98(?![\d.,])'),
    FuelType.Ai95: RegExp(r'(?<![\d.,])95(?![\d.,])'),
    FuelType.Ai92: RegExp(r'(?<![\d.,])92(?![\d.,])'),
  };

  /// The fuel named in [lines], or null when none or several different ones
  /// are (a frame with a neighbouring pump) - better to leave the choice to
  /// the user than to pick the wrong one.
  static FuelType? detect(Iterable<String> lines) {
    final found = <FuelType>{};
    for (final line in lines) {
      for (final entry in _labels.entries) {
        if (entry.value.hasMatch(line)) found.add(entry.key);
      }
    }
    return found.length == 1 ? found.first : null;
  }
}
