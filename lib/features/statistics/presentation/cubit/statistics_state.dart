

import 'package:fines_plus/core/extensions/monthly_expense_stats.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';

/// One month's expense total (in the base currency), [month] being the
/// first day of that month.
typedef MonthTotal = ({DateTime month, double total});

class StatisticsState {
  final bool loading;
  final double currentMonthMileage;
  final double averageMileage;
  final MonthlyExpenseStats expenseStats;
  final MonthlyExpenseStats previousExpenseStats;
  final List<FuelRecord> fuelRecords;
  final double averageFuelConsumption;
  final double previousMonthMileage;
  final int lastOdometer;

  /// Expense totals for the last 12 months, oldest first, the current month
  /// last - feeds the dashboard expense chart.
  final List<MonthTotal> recentMonths;

  StatisticsState({
    required this.loading,
    required this.currentMonthMileage,
    required this.averageMileage,
    required this.expenseStats,
    required this.previousExpenseStats,
    required this.fuelRecords,
    required this.averageFuelConsumption,
    required this.previousMonthMileage,
    required this.lastOdometer,
    this.recentMonths = const [],
  });

  factory StatisticsState.initial() => StatisticsState(
    loading: true,
    currentMonthMileage: 0,
    averageMileage: 0,
    expenseStats: MonthlyExpenseStats.initial(),
    previousExpenseStats: MonthlyExpenseStats.initial(),
    fuelRecords: [],
    averageFuelConsumption: 0,
    previousMonthMileage: 0,
    lastOdometer: 0,
  );

  StatisticsState copyWith({
    bool? loading,
    double? currentMonthMileage,
    double? averageMileage,
    MonthlyExpenseStats? expenseStats,
    MonthlyExpenseStats? previousExpenseStats,
    List<FuelRecord>? fuelRecords,
    double? averageFuelConsumption,
    double? previousMonthMileage,
    int? lastOdometer,
    List<MonthTotal>? recentMonths,
  }) {
    return StatisticsState(
      loading: loading ?? this.loading,
      currentMonthMileage: currentMonthMileage ?? this.currentMonthMileage,
      averageMileage: averageMileage ?? this.averageMileage,
      expenseStats: expenseStats ?? this.expenseStats,
      previousExpenseStats: previousExpenseStats ?? this.previousExpenseStats,
      fuelRecords: fuelRecords ?? this.fuelRecords,
      averageFuelConsumption: averageFuelConsumption ?? this.averageFuelConsumption,
      previousMonthMileage: previousMonthMileage ?? this.previousMonthMileage,
      lastOdometer: lastOdometer ?? this.lastOdometer,
      recentMonths: recentMonths ?? this.recentMonths,
    );
  }
}
