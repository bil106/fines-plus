import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';

class MonthlyExpenseStats {
  final String monthLabel;
  final double total;
  final Map<ExpenseCategory, double> categoryTotals;

  MonthlyExpenseStats({required this.monthLabel, required this.total, required this.categoryTotals});
}

MonthlyExpenseStats calculateMonthlyStats(List<Map<String, dynamic>> expenseJson, int year, int month) {
  double total = 0;
  final monthLabel = VehicleFormatters.formatMonthYear(DateTime(year, month));

  final categoryTotals = <ExpenseCategory, double>{
    ExpenseCategory.fuel: 0,
    ExpenseCategory.service: 0,
    ExpenseCategory.tuning: 0,
    ExpenseCategory.other: 0,
  };

  for (final e in expenseJson) {
    final date = DateTime.parse(e['date'] as String);
    if (date.year != year || date.month != month) continue;

    final rawAmount = (e['amount'] as String).replaceAll(RegExp(r'[^\d.]'), '');
    final value = double.tryParse(rawAmount) ?? 0;

    total += value;

    final categoryString = e['category'] as String? ?? 'other';
    ExpenseCategory category = ExpenseCategory.other;
    switch (categoryString.toLowerCase()) {
      case 'fuel':
        category = ExpenseCategory.fuel;
        break;
      case 'service':
        category = ExpenseCategory.service;
        break;
      case 'tuning':
        category = ExpenseCategory.tuning;
        break;
      case 'other':
        category = ExpenseCategory.other;
        break;
    }

    categoryTotals[category] = (categoryTotals[category] ?? 0) + value;
  }

  return MonthlyExpenseStats(monthLabel: monthLabel, total: total, categoryTotals: categoryTotals);
}
