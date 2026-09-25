import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a fuel record keeps its cents and currency through Firestore', () {
    final record = FuelRecord(
      fuelType: 'Gasoline',
      volume: 12.4,
      cost: 43.27,
      date: DateTime(2026, 9, 25),
      mileage: 108198,
      currency: 'USD',
    );

    final stored = record.toExpense('owner').toFirestore(isNew: true);
    final loaded = FuelRecord.fromExpense(Expense.fromFirestore(stored, id: 'doc'));

    expect(loaded.cost, 43.27);
    expect(loaded.currency, 'USD');
  });

  test('older whole-number documents still load', () {
    final loaded = Expense.fromFirestore({
      'date': '2025-01-10T00:00:00.000',
      'amount': 1200,
      'category': 'fuel',
      'ownerId': 'owner',
    }, id: 'doc');

    expect(loaded.amount, 1200.0);
    expect(loaded.currency, 'UAH');
  });
}
