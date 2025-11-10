import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';
import 'expense_record.dart';

part 'monthly_expense_stats.g.dart';

@JsonSerializable()
class MonthlyExpenseStats {
  final String monthLabel;
  final double total;
  final Map<ExpenseCategory, double> categoryTotals;

  MonthlyExpenseStats({required this.monthLabel, required this.total, required this.categoryTotals});

  factory MonthlyExpenseStats.fromJson(Map<String, dynamic> json) => _$MonthlyExpenseStatsFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyExpenseStatsToJson(this);
factory MonthlyExpenseStats.initial() {
    return MonthlyExpenseStats(
      monthLabel: '',
      total: 0.0,
      categoryTotals: {
        ExpenseCategory.fuel: 0.0,
        ExpenseCategory.service: 0.0,
        ExpenseCategory.tuning: 0.0,
        ExpenseCategory.carWash: 0.0,
        ExpenseCategory.other: 0.0,
      },);}


}

MonthlyExpenseStats calculateMonthlyStats(List<ExpenseRecord> expenses, int year, int month) {
  double total = 0;
  final monthLabel = "${month.toString().padLeft(2, '0')}/$year";

  final categoryTotals = <ExpenseCategory, double>{
    ExpenseCategory.fuel: 0,
    ExpenseCategory.service: 0,
    ExpenseCategory.tuning: 0,
    ExpenseCategory.carWash: 0,
    ExpenseCategory.other: 0,
  };

  for (final e in expenses) {
    final date = DateTime.parse(e.date);
    if (date.year != year || date.month != month) continue;

    total += e.amount;
    categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
  }

  return MonthlyExpenseStats(monthLabel: monthLabel, total: total, categoryTotals: categoryTotals);



}
