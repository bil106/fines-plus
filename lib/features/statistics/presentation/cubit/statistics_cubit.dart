import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/extensions/fuel_calculator.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/core/extensions/monthly_expense_stats.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
class StatisticsCubit extends Cubit<StatisticsState> {
  final MaintenanceCubit maintenanceCubit;
  late final StreamSubscription<MaintenanceState> _maintenanceSub;

  StatisticsCubit(this.maintenanceCubit) : super(StatisticsState.initial()) {

    _recalculate(maintenanceCubit.state);


    _maintenanceSub = maintenanceCubit.stream.listen(_recalculate);
  }

  Future<void> _recalculate(MaintenanceState maintenanceState) async {
    if (isClosed) return;

    final now = DateTime.now();

    final currentMonthMileage = maintenanceCubit.getCurrentMonthMileage(now);
    final averageMileage = maintenanceCubit.getAverageMileage();


    final prevMonthDate = DateTime(now.year, now.month, 0);
    final previousMonthMileage = maintenanceCubit.getCurrentMonthMileage(prevMonthDate);

  
    final expenseStats = _calculateMonthlyStats(maintenanceState, now.year, now.month);
    final prevExpenseStats = _calculateMonthlyStats(maintenanceState, prevMonthDate.year, prevMonthDate.month);

  
    double avgFuelConsumption = 0.0;
    try {
      if (maintenanceState.fuelRecords.isNotEmpty) {
        avgFuelConsumption = await calculateAverageFuelConsumptionAsync(maintenanceState.fuelRecords);
      }
    } catch (e, st) {
      debugPrint('Error calculating average fuel: $e\n$st');
    }

    if (isClosed) return;

    emit(
      StatisticsState(
        loading: false,
        currentMonthMileage: currentMonthMileage.toDouble(),
        averageMileage: averageMileage.toDouble(),
        previousMonthMileage: previousMonthMileage.toDouble(),
        lastOdometer: _getLastOdometer(maintenanceState),
        expenseStats: expenseStats,
        previousExpenseStats: prevExpenseStats,
        fuelRecords: maintenanceState.fuelRecords,
        averageFuelConsumption: avgFuelConsumption,
      ),
    );
  }

  int _getLastOdometer(MaintenanceState state) {
    final mileages = [
      ...state.fuelRecords.map((e) => e.mileage),
      ...state.serviceRecords.map((e) => e.mileage),
      ...state.carWashRecords.map((e) => e.mileage),
      ...state.tuningRecords.map((e) => e.mileage),
      ...state.otherRecords.map((e) => e.mileage),
    ];
    return mileages.isEmpty ? 0 : mileages.fold<int>(0, (a, b) => a > b ? a : b);
  }

  MonthlyExpenseStats _calculateMonthlyStats(MaintenanceState state, int year, int month) {
    double total = 0;
    double electricTotal = 0;
    final categoryTotals = <ExpenseCategory, double>{
      ExpenseCategory.fuel: 0,
      ExpenseCategory.service: 0,
      ExpenseCategory.tuning: 0,
      ExpenseCategory.carWash: 0,
      ExpenseCategory.insurance: 0,
      ExpenseCategory.other: 0,
    };

    final recordsMap = {
      ExpenseCategory.service: state.serviceRecords,
      ExpenseCategory.fuel: state.fuelRecords,
      ExpenseCategory.tuning: state.tuningRecords,
      ExpenseCategory.carWash: state.carWashRecords,
      ExpenseCategory.insurance: state.insuranceRecords,
      ExpenseCategory.other: state.otherRecords,
    };

    for (var entry in recordsMap.entries) {
      for (var record in entry.value) {
        final date = (record is ServiceRecord) ? _parseDate(record.date) : (record as dynamic).date;
        if (date.year != year || date.month != month) continue;

        final cost = (record is CarWashRecord) ? record.amount : (record as dynamic).cost;
        total += cost;
        categoryTotals[entry.key] = (categoryTotals[entry.key] ?? 0) + cost;
        if (record is FuelRecord && record.fuelType == FuelType.Electric.name) electricTotal += cost;
      }
    }

    return MonthlyExpenseStats(
      monthLabel: "${_monthName(month)} $year",
      total: total,
      categoryTotals: categoryTotals,
      electricTotal: electricTotal,
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('dd.MM.yyyy').parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  String _monthName(int month) {
    final fallback = ["Січ", "Лют", "Бер", "Квіт", "Трав", "Черв", "Лип", "Серп", "Верес", "Жовт", "Лист", "Груд"];
    try {
      final months = [
        S.current.month_jan,
        S.current.month_feb,
        S.current.month_mar,
        S.current.month_apr,
        S.current.month_may,
        S.current.month_jun,
        S.current.month_jul,
        S.current.month_aug,
        S.current.month_sep,
        S.current.month_oct,
        S.current.month_nov,
        S.current.month_dec,
      ];
      return months[month - 1];
    } catch (_) {
      return fallback[month - 1];
    }
  }


void clearStats() {
    emit(
      StatisticsState(
        loading: false,
        currentMonthMileage: 0,
        averageMileage: 0,
        previousMonthMileage: 0,
        lastOdometer: 0,
        expenseStats: MonthlyExpenseStats.empty(),
        previousExpenseStats: MonthlyExpenseStats.empty(),
        fuelRecords: const [],
        averageFuelConsumption: 0.0,
      ),
    );
  }


  @override
  Future<void> close() {
    _maintenanceSub.cancel();
    return super.close();
  }
}
