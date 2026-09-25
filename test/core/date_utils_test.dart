import 'package:fines_plus/core/helpers/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('uk');
  });

  final date = DateTime(2026, 9, 25);

  test('English app shows English months', () {
    expect(formatShortDate(date, 'en'), '25 Sep');
    expect(formatShortDate(date, 'en', withYear: true), '25 Sep 2026');
  });

  test('Ukrainian app keeps its compact dates', () {
    expect(formatShortDate(date, 'uk'), '25 вер');
    expect(formatShortDate(date, 'uk', withYear: true), '25 вер 2026');
  });
}
