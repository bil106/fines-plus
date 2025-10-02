
import 'package:fines_plus/core/widgets/extensions/monthly_expense_stats.dart';

class StatisticsState {
  final bool loading;
  final int currentMonthMileage;
  final int averageMileage;
  final List<MonthlyExpenseStats> expenses; 

  const StatisticsState({
    required this.loading,
    required this.currentMonthMileage,
    required this.averageMileage,
    required this.expenses,
  });

  factory StatisticsState.initial() => const StatisticsState(
        loading: true,
        currentMonthMileage: 0,
        averageMileage: 0,
        expenses: [],
      );

  StatisticsState copyWith({
    bool? loading,
    int? currentMonthMileage,
    int? averageMileage,
    List<MonthlyExpenseStats>? expenses,
  }) {
    return StatisticsState(
      loading: loading ?? this.loading,
      currentMonthMileage: currentMonthMileage ?? this.currentMonthMileage,
      averageMileage: averageMileage ?? this.averageMileage,
      expenses: expenses ?? this.expenses,
    );
  }
}
