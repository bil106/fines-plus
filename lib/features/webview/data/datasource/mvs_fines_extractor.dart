import 'dart:convert';

/// Reads the resolution list off the results page of bdr.mvs.gov.ua.
///
/// The page is rendered server-side: every `.item` inside `.resolution-list`
/// holds the amount, description and date, is followed by a sibling link
/// `/user/resolution/<series>/<number>/`, and carries the `paid` class once
/// the fine is settled.
class MvsFinesExtractor {
  static const resultsPathPrefix = '/main/sub/';

  static const extractJs = r'''
(function () {
  var root = document.querySelector('.search-result');
  if (!root) return JSON.stringify({ok: false, fines: []});
  var fines = [];
  root.querySelectorAll('.resolution-list .item').forEach(function (item) {
    var link = item.nextElementSibling;
    var text = function (sel) {
      var el = item.querySelector(sel);
      return el ? el.textContent.trim() : '';
    };
    fines.push({
      href: link && link.tagName === 'A' ? link.getAttribute('href') : '',
      amount: text('.amount'),
      description: text('.descr'),
      date: text('.resolution-datetime'),
      paid: item.classList.contains('paid')
    });
  });
  return JSON.stringify({ok: true, fines: fines});
})();
''';

  /// Fines in the shape the fines screen reads, or null when the page is not
  /// a results page (layout changed, error page, ...).
  static List<Map<String, dynamic>>? parse(Object? raw) {
    if (raw is! String) return null;
    var data = jsonDecode(raw);
    if (data is String) data = jsonDecode(data);
    if (data is! Map || data['ok'] != true) return null;
    final items = data['fines'] as List;
    return [
      for (final entry in items.asMap().entries)
        _toFine(entry.key, Map<String, dynamic>.from(entry.value as Map)),
    ];
  }

  static Map<String, dynamic> _toFine(int index, Map<String, dynamic> item) {
    return {
      'id': _fineId(item['href']?.toString() ?? '', index),
      'description': item['description'],
      'amount': _amount(item['amount']?.toString() ?? ''),
      'date': _isoDate(item['date']?.toString() ?? ''),
      'paid': item['paid'] == true,
    };
  }

  /// `/user/resolution/5АВ/11506008/` -> `5АВ-11506008`.
  static String _fineId(String href, int index) {
    final segments = Uri.parse(href).pathSegments.where((s) => s.isNotEmpty);
    return segments.length > 3 ? segments.skip(2).join('-') : '$index';
  }

  /// `340,00 грн` -> 340.0
  static double _amount(String raw) {
    const allowed = '0123456789,';
    final digits = raw.split('').where(allowed.contains).join();
    return double.tryParse(digits.replaceAll(',', '.')) ?? 0;
  }

  /// `19.07.2025` -> `2025-07-19` (left as is if it isn't dd.MM.yyyy).
  static String _isoDate(String raw) {
    final parts = raw.split('.');
    if (parts.length != 3) return raw;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }
}
