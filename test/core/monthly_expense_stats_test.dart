import 'package:fines_plus/core/extensions/monthly_expense_stats.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MonthlyExpenseStats.electricTotal', () {
    test('survives a JSON round trip', () {
      final stats = MonthlyExpenseStats(
        monthLabel: 'Верес 2026',
        total: 5000,
        categoryTotals: {ExpenseCategory.fuel: 3000, ExpenseCategory.service: 2000},
        electricTotal: 850,
      );
      final restored = MonthlyExpenseStats.fromJson(stats.toJson());
      expect(restored.electricTotal, 850);
      expect(restored.categoryTotals[ExpenseCategory.fuel], 3000);
    });

    test('is 0 for data saved before it existed', () {
      final restored = MonthlyExpenseStats.fromJson({
        'monthLabel': 'Верес 2026',
        'total': 100,
        'categoryTotals': {'fuel': 100},
      });
      expect(restored.electricTotal, 0);
    });
  });
}
