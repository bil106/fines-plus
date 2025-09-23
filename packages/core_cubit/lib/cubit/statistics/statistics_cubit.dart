import 'dart:async';


import 'package:bloc/bloc.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_cubit.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_state.dart';
import 'package:core_cubit/cubit/statistics/statistics_state.dart';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/widgets/extensions/monthly_expense_stats.dart';
import 'package:intl/intl.dart';


class StatisticsCubit extends Cubit<StatisticsState> {
  final MaintenanceCubit maintenanceCubit;
  late final StreamSubscription maintenanceSub;

  StatisticsCubit(this.maintenanceCubit) : super(StatisticsState.initial()) {
  
    _recalculate(maintenanceCubit.state);

   
    maintenanceSub = maintenanceCubit.stream.listen((maintenanceState) {
      _recalculate(maintenanceState);
    });
  }

  void _recalculate(MaintenanceState maintenanceState) {
    final now = DateTime.now();

    final currentMonthMileage = maintenanceCubit.getCurrentMonthMileage(now);
    final averageMileage = maintenanceCubit.getAverageMileage();

    final expenseStats = _calculateMonthlyStats(
      serviceRecords: maintenanceState.serviceRecords,
      fuelRecords: maintenanceState.fuelRecords,
      year: now.year,
      month: now.month,
    );

    emit(
      state.copyWith(
        loading: false,
        currentMonthMileage: currentMonthMileage,
        averageMileage: averageMileage,
        expenseStats: expenseStats,
      ),
    );
  }

  @override
  Future<void> close() {
    maintenanceSub.cancel();
    return super.close();
  }

MonthlyExpenseStats _calculateMonthlyStats({
    required List<ServiceRecord> serviceRecords,
    required List<FuelRecord> fuelRecords,
    required int year,
    required int month,
  }) {
    double total = 0;
    final categoryTotals = <ExpenseCategory, double>{
      ExpenseCategory.fuel: 0,
      ExpenseCategory.service: 0,
      ExpenseCategory.tuning: 0, 
      ExpenseCategory.other: 0,
    };

    DateTime parseDate(String dateStr) {
      try {
        return DateFormat('dd.MM.yyyy').parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }

    for (final s in serviceRecords) {
      final date = parseDate(s.date);
      if (date.year != year || date.month != month) continue;
      total += s.cost;
      categoryTotals[ExpenseCategory.service] = (categoryTotals[ExpenseCategory.service] ?? 0) + s.cost;
    }

    for (final f in fuelRecords) {
      final date = parseDate(f.date);
      if (date.year != year || date.month != month) continue;
      total += f.cost;
      categoryTotals[ExpenseCategory.fuel] = (categoryTotals[ExpenseCategory.fuel] ?? 0) + f.cost;
    }

  
    for (final t in maintenanceCubit.state.tuningRecords) {
      final date = parseDate(t.date);
      if (date.year != year || date.month != month) continue;
      total += t.cost;
      categoryTotals[ExpenseCategory.tuning] = (categoryTotals[ExpenseCategory.tuning] ?? 0) + t.cost;
    }

    final monthLabel = _monthName(month);

    return MonthlyExpenseStats(
      monthLabel: "$monthLabel $year",
      total: total,
      categoryTotals: categoryTotals,
    );
  }


  String _monthName(int month) {
    const months = ["Січ", "Лют", "Бер", "Квіт", "Трав", "Черв", "Лип", "Серп", "Верес", "Жовт", "Лист", "Груд"];
    return months[month - 1];
  }
}
