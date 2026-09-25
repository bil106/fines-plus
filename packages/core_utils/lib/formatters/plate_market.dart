import 'package:core_localization/generated/l10n.dart';

/// Licence-plate conventions of a brand's market (`AppConfig.market`), so
/// plate input, validation and the dashboard plate badge all follow the
/// same rules instead of each assuming the Ukrainian format.
enum PlateMarket {
  /// `AA1234BB` - 2 letters, 4 digits, 2 letters.
  ua(slots: 'LLDDDDLL', maxLength: 8),

  /// `1234BCD` - 4 digits, 3 consonants (no vowels, Ñ or Q on real plates).
  es(slots: 'DDDDLLL', maxLength: 7),

  /// Free-form: every US state has its own format, vanity plates included,
  /// so only length and characters are checked.
  us(slots: null, maxLength: 8);

  const PlateMarket({required this.slots, required this.maxLength});

  /// One character per plate position: `L` letter, `D` digit. Null means
  /// free-form letters/digits up to [maxLength].
  final String? slots;
  final int maxLength;

  static final _digit = RegExp(r'\d');
  static final _anyLetter = RegExp(r'[A-Z]');
  static final _esLetter = RegExp(r'[BCDFGHJKLMNPRSTVWXYZ]');
  static final _alphanumeric = RegExp(r'[A-Z0-9]');

  /// `AppConfig.market` code -> plate rules. Any market without its own
  /// rules yet gets the permissive free-form ones rather than the strict
  /// Ukrainian pattern, which would make its plates impossible to enter.
  static PlateMarket fromCode(String market) => switch (market.toUpperCase()) {
        'UA' => PlateMarket.ua,
        'ES' => PlateMarket.es,
        _ => PlateMarket.us,
      };

  bool isLetter(String char) => (this == es ? _esLetter : _anyLetter).hasMatch(char);

  bool isDigit(String char) => _digit.hasMatch(char);

  bool isAlphanumeric(String char) => _alphanumeric.hasMatch(char);

  /// A complete plate for this market (expects the stored, uppercase form
  /// without spaces).
  bool isValid(String value) {
    final plate = value.toUpperCase();
    final pattern = slots;
    if (pattern == null) {
      return plate.isNotEmpty && plate.length <= maxLength && plate.split('').every(isAlphanumeric);
    }
    if (plate.length != pattern.length) return false;
    for (var i = 0; i < pattern.length; i++) {
      final ok = pattern[i] == 'L' ? isLetter(plate[i]) : isDigit(plate[i]);
      if (!ok) return false;
    }
    return true;
  }

  /// How the plate is printed on the badge: `AA 1234 BB` / `1234 BCD`;
  /// free-form or non-standard plates are shown as typed.
  String display(String raw) {
    final plate = raw.replaceAll(' ', '').toUpperCase();
    if (!isValid(plate)) return raw.toUpperCase();
    return switch (this) {
      ua => '${plate.substring(0, 2)} ${plate.substring(2, 6)} ${plate.substring(6)}',
      es => '${plate.substring(0, 4)} ${plate.substring(4)}',
      us => plate,
    };
  }

  /// Example plate shown as the input hint.
  String get hint => switch (this) {
        ua => S.current.hint_auto_num,
        es => S.current.hint_auto_num_es,
        us => S.current.hint_auto_num_us,
      };
}
