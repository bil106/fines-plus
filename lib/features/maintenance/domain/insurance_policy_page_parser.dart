/// What the MTSBU policy-check page (the one an OSCPV policy's QR code leads
/// to) says about a policy. It never carries the premium.
class InsurancePolicyInfo {
  final String policyNumber;
  final String company;
  final DateTime validFrom;
  final DateTime validTo;

  /// Plate of the insured vehicle as printed on the page, for checking the
  /// policy belongs to the active car.
  final String plate;

  const InsurancePolicyInfo({
    required this.policyNumber,
    required this.company,
    required this.validFrom,
    required this.validTo,
    required this.plate,
  });

  static const _cyrillicToLatin = {
    'А': 'A', 'В': 'B', 'Е': 'E', 'І': 'I', 'К': 'K', 'М': 'M',
    'Н': 'H', 'О': 'O', 'Р': 'P', 'С': 'C', 'Т': 'T', 'Х': 'X',
  };

  /// Plates are typed with Latin or look-alike Cyrillic letters depending on
  /// the source, so both sides are compared in Latin. Unknown plates on
  /// either side count as a match - there's nothing to contradict.
  bool matchesPlate(String carNumber) {
    final policy = _normalize(plate);
    final car = _normalize(carNumber);
    return policy.isEmpty || car.isEmpty || policy == car;
  }

  static String _normalize(String value) => value
      .toUpperCase()
      .replaceAll(' ', '')
      .split('')
      .map((char) => _cyrillicToLatin[char] ?? char)
      .join();
}

/// Reads the Ukrainian-language policy-check page as plain text: each value
/// sits on the line right after its label. Returns null when the page isn't
/// that page (other layout or language), so callers fall back to manual
/// entry rather than filling wrong values.
class InsurancePolicyPageParser {
  static const _startLabel = 'Дата та час початку строку дії Договору';
  static const _endLabel = 'Дата закінчення строку дії Договору';
  static const _companyLabel = 'Найменування';
  static const _plateLabel = 'Реєстраційний номер';

  static final _scriptsAndStyles = RegExp(r'<(script|style)[\s\S]*?</\1>', caseSensitive: false);
  static final _tags = RegExp(r'<[^>]+>');
  static final _policyNumber = RegExp(r'поліс\s*№\s*(\d+)');
  static final _date = RegExp(r'(\d{2})\.(\d{2})\.(\d{4})');
  static final _numericEntity = RegExp(r'&#(x[0-9a-fA-F]+|\d+);');

  static InsurancePolicyInfo? parse(String html) {
    final lines = html
        .replaceAll(_scriptsAndStyles, '')
        .replaceAll(_tags, '\n')
        .split('\n')
        .map((line) => _unescape(line).trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final number = lines.map(_policyNumber.firstMatch).whereType<RegExpMatch>().firstOrNull?.group(1);
    final company = _valueAfter(lines, _companyLabel);
    final from = _dateAfter(lines, _startLabel);
    final to = _dateAfter(lines, _endLabel);
    if (number == null || company == null || from == null || to == null) return null;

    return InsurancePolicyInfo(
      policyNumber: number,
      company: company,
      validFrom: from,
      validTo: to,
      plate: _valueAfter(lines, _plateLabel) ?? '',
    );
  }

  static String? _valueAfter(List<String> lines, String label) {
    final index = lines.indexOf(label);
    return index == -1 || index + 1 >= lines.length ? null : lines[index + 1];
  }

  static DateTime? _dateAfter(List<String> lines, String label) {
    final match = _date.firstMatch(_valueAfter(lines, label) ?? '');
    if (match == null) return null;
    return DateTime(int.parse(match.group(3)!), int.parse(match.group(2)!), int.parse(match.group(1)!));
  }

  static String _unescape(String text) => text
      .replaceAllMapped(_numericEntity, (match) {
        final code = match.group(1)!;
        final value = code.startsWith('x') ? int.parse(code.substring(1), radix: 16) : int.parse(code);
        return String.fromCharCode(value);
      })
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&laquo;', '«')
      .replaceAll('&raquo;', '»')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&');
}
