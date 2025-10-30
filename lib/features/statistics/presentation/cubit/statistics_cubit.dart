import 'dart:async';


import 'package:bloc/bloc.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/core/extensions/monthly_expense_stats.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
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
      carWashRecords: maintenanceState.carWashRecords,
      tuningRecords: maintenanceState.tuningRecords,
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
    required List<CarWashRecord> carWashRecords,
    required List<TuningRecord> tuningRecords,
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
      final date = parseDate(f.date.toString());
      if (date.year != year || date.month != month) continue;
      total += f.cost;
      categoryTotals[ExpenseCategory.fuel] = (categoryTotals[ExpenseCategory.fuel] ?? 0) + f.cost;
    }
    for (final c in carWashRecords) {
      final date = parseDate(c.date.toString());
      if (date.year != year || date.month != month) continue;
      total += c.amount;
      categoryTotals[ExpenseCategory.other] = (categoryTotals[ExpenseCategory.other] ?? 0) + c.amount;
    }
  
    for (final c in tuningRecords) {
      final date = parseDate(c.date);
      if (date.year != year || date.month != month) continue;
      total += c.cost;
      categoryTotals[ExpenseCategory.tuning] = (categoryTotals[ExpenseCategory.tuning] ?? 0) + c.cost;
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
