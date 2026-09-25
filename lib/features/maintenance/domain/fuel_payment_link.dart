/// Deep link a phone-payment automation opens right after paying for fuel:
/// `<bundle id / applicationId>://fuel?amount=1250.50`. Sent by the iOS
/// "Add fuel-up" shortcut action (see `ios/Runner/AddFuelUpIntent.swift`),
/// or built by hand in Shortcuts / Tasker / MacroDroid.
class FuelPaymentLink {
  const FuelPaymentLink._();

  static const String _host = 'fuel';

  static bool matches(Uri uri) =>
      uri.host == _host && !uri.isScheme('http') && !uri.isScheme('https');

  /// The paid total, or null when it's missing / not a positive number.
  /// Tolerates what Shortcuts' "Amount" variable turns into as text, e.g.
  /// `1250.5`, `1 250,50 ₴`, `₴1,250.50`.
  static double? amountFrom(Uri uri) {
    final raw = uri.queryParameters['amount'];
    if (raw == null) return null;
    var text = raw.replaceAll(RegExp(r'[^0-9.,]'), '');
    final lastDot = text.lastIndexOf('.');
    final lastComma = text.lastIndexOf(',');
    if (lastDot >= 0 && lastComma >= 0) {
      // Both present: the later one is the decimal separator.
      final decimal = lastDot > lastComma ? '.' : ',';
      final grouping = decimal == '.' ? ',' : '.';
      text = text.replaceAll(grouping, '').replaceAll(decimal, '.');
    } else if (lastComma >= 0) {
      // "1,250" groups thousands, "1250,5" / "1250,50" is a decimal part.
      final isGrouping = text.length - lastComma - 1 == 3;
      text = text.replaceAll(',', isGrouping ? '' : '.');
    }
    final amount = double.tryParse(text);
    return amount != null && amount > 0 ? amount : null;
  }
}
