import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/widgets/extensions/monthly_expense_stats.dart';

class StatisticsState {
  final bool loading;
  final List<MileageRecord> mileageRecords;
  final List<ServiceRecord> serviceRecords;
  final List<FuelRecord> fuelRecords;
  final MonthlyExpenseStats? expenseStats;

  StatisticsState({
    required this.loading,
    required this.mileageRecords,
    required this.serviceRecords,
    required this.fuelRecords,
    required this.expenseStats,
  });

  factory StatisticsState.initial() => StatisticsState(
        loading: true,
        mileageRecords: [],
        serviceRecords: [],
        fuelRecords: [],
        expenseStats: null,
      );

  StatisticsState copyWith({
    bool? loading,
    List<MileageRecord>? mileageRecords,
    List<ServiceRecord>? serviceRecords,
    List<FuelRecord>? fuelRecords,
    MonthlyExpenseStats? expenseStats,
  }) {
    return StatisticsState(
      loading: loading ?? this.loading,
      mileageRecords: mileageRecords ?? this.mileageRecords,
      serviceRecords: serviceRecords ?? this.serviceRecords,
      fuelRecords: fuelRecords ?? this.fuelRecords,
      expenseStats: expenseStats ?? this.expenseStats,
    );
  }
}
