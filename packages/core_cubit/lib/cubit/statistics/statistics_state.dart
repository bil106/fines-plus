
import 'package:fines_plus/core/widgets/extensions/monthly_expense_stats.dart';

class StatisticsState {
  final bool loading;
  final int currentMonthMileage;
  final int averageMileage;
  final MonthlyExpenseStats? expenseStats;

  const StatisticsState({
    required this.loading,
    required this.currentMonthMileage,
    required this.averageMileage,
    required this.expenseStats,
  });

  factory StatisticsState.initial() => const StatisticsState(
        loading: false,
        currentMonthMileage: 0,
        averageMileage: 0,
        expenseStats: null,
      );

  StatisticsState copyWith({
    bool? loading,
    int? currentMonthMileage,
    int? averageMileage,
    MonthlyExpenseStats? expenseStats,
  }) {
    return StatisticsState(
      loading: loading ?? this.loading,
      currentMonthMileage: currentMonthMileage ?? this.currentMonthMileage,
      averageMileage: averageMileage ?? this.averageMileage,
      expenseStats: expenseStats ?? this.expenseStats,
    );
  }
}
