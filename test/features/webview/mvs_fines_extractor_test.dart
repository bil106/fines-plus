import 'dart:convert';

import 'package:fines_plus/features/webview/data/datasource/mvs_fines_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the MVS results list to fines', () {
    final raw = jsonEncode({
      'ok': true,
      'fines': [
        {
          'href': '/user/resolution/5АВ/11506008/',
          'amount': '340,00 грн',
          'description': 'Перевищення встановлених обмежень швидкості руху',
          'date': '19.07.2025',
          'paid': true,
        },
        {
          'href': '/user/resolution/4АВ/07984913/',
          'amount': '1 020,50 грн',
          'description': 'Паркування',
          'date': '20.10.2024',
          'paid': false,
        },
      ],
    });

    final fines = MvsFinesExtractor.parse(raw)!;

    expect(fines, hasLength(2));
    expect(fines[0], {
      'id': '5АВ-11506008',
      'description': 'Перевищення встановлених обмежень швидкості руху',
      'amount': 340.0,
      'date': '2025-07-19',
      'paid': true,
    });
    expect(fines[1]['amount'], 1020.5);
    expect(fines[1]['paid'], false);
  });

  test('accepts a double-encoded JS result and falls back to the index id', () {
    final inner = jsonEncode({
      'ok': true,
      'fines': [
        {'href': '', 'amount': '10,00 грн', 'description': 'x', 'date': '', 'paid': false},
      ],
    });
    expect(MvsFinesExtractor.parse(jsonEncode(inner))!.single['id'], '0');
  });

  test('an empty results page yields an empty list, a foreign page yields null', () {
    expect(MvsFinesExtractor.parse('{"ok":true,"fines":[]}'), isEmpty);
    expect(MvsFinesExtractor.parse('{"ok":false,"fines":[]}'), isNull);
    expect(MvsFinesExtractor.parse(null), isNull);
  });
}
