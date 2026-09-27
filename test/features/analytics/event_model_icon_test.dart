import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

EventModel _event(int codePoint) => EventModel(
  date: DateTime(2026, 9, 27),
  title: 'Test',
  amount: 1,
  mileage: '',
  iconCodePoint: codePoint,
  iconColorValue: 0,
  category: ExpenseCategory.fuel,
);

void main() {
  test('event icons resolve to the same constant Material icons', () {
    for (final icon in [
      Icons.local_gas_station,
      Icons.build,
      Icons.build_circle,
      Icons.local_car_wash,
      Icons.gpp_good,
      Icons.more_horiz,
    ]) {
      expect(_event(icon.codePoint).icon, icon);
    }
  });

  test('an unknown code point falls back to the "other" icon', () {
    expect(_event(0).icon, Icons.more_horiz);
  });
}
