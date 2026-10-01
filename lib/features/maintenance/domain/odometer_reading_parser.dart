/// Picks the odometer value out of the text lines recognised on a photo of
/// the dashboard, which also carries a trip meter, clock, temperature, etc.
class OdometerReadingParser {
  const OdometerReadingParser._();

  static const int _maxReading = 999999;

  /// The most likely odometer reading, or null when nothing plausible is
  /// there. An odometer never runs backwards, so values at or above
  /// [lastKnown] are preferred - but when there are none (another car, a
  /// corrected record) the reading is still offered rather than refused,
  /// since the user sees and can edit it. Of the candidates the longest
  /// number wins (the trip meter and clock are shorter), then the larger one.
  static int? parse(Iterable<String> lines, {int? lastKnown}) {
    final candidates = <int>[];
    for (final line in lines) {
      // "132 150" / "132,150" / "132.150" are one number, not two.
      final joined = line.replaceAllMapped(
        RegExp(r'(?<=\d)[ ,.](?=\d{3}(?!\d))'),
        (_) => '',
      );
      for (final match in RegExp(r'\d+').allMatches(joined)) {
        final value = int.tryParse(match.group(0)!);
        if (value == null || value > _maxReading) continue;
        candidates.add(value);
      }
    }
    if (candidates.isEmpty) return null;
    final plausible = lastKnown == null ? candidates : candidates.where((value) => value >= lastKnown).toList();
    final pool = plausible.isEmpty ? candidates : plausible;
    pool.sort((a, b) {
      final byLength = b.toString().length.compareTo(a.toString().length);
      return byLength != 0 ? byLength : b.compareTo(a);
    });
    return pool.first;
  }
}
