import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fines_plus/core/extensions/fuel_calculator.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/core/extensions/monthly_expense_stats.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:flutter/foundation.dart';
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

  void _recalculate(MaintenanceState maintenanceState) async {
    if (isClosed) return;

    final now = DateTime.now();

    final currentMonthMileage = maintenanceCubit.getCurrentMonthMileage(now);
    final averageMileage = maintenanceCubit.getAverageMileage();

    final prevMonthDate = DateTime(now.year, now.month - 1);
    final previousMonthMileage = maintenanceCubit.getCurrentMonthMileage(prevMonthDate);

    final expenseStats = _calculateMonthlyStats(
      serviceRecords: maintenanceState.serviceRecords,
      fuelRecords: maintenanceState.fuelRecords,
      carWashRecords: maintenanceState.carWashRecords,
      tuningRecords: maintenanceState.tuningRecords,
      year: now.year,
      month: now.month,
    );

    final prevExpenseStats = _calculateMonthlyStats(
      serviceRecords: maintenanceState.serviceRecords,
      fuelRecords: maintenanceState.fuelRecords,
      carWashRecords: maintenanceState.carWashRecords,
      tuningRecords: maintenanceState.tuningRecords,
      year: prevMonthDate.year,
      month: prevMonthDate.month,
    );

    double avgFuelConsumption = 0.0;
    try {
      if (maintenanceState.fuelRecords.isNotEmpty) {
        avgFuelConsumption = await calculateAverageFuelConsumptionAsync(maintenanceState.fuelRecords);
      }
    } catch (e, st) {
      debugPrint('Error calculating average fuel: $e\n$st');
    }

    final lastOdometer = _getLastOdometer(maintenanceState);

    emit(
      state.copyWith(
        loading: false,
        currentMonthMileage: currentMonthMileage.toDouble(),
        averageMileage: averageMileage.toDouble(),
        expenseStats: expenseStats,
        previousExpenseStats: prevExpenseStats,
        fuelRecords: maintenanceState.fuelRecords,
        averageFuelConsumption: avgFuelConsumption,
        previousMonthMileage: previousMonthMileage.toDouble(),
        lastOdometer: lastOdometer,
      ),
    );
  }

  int _getLastOdometer(MaintenanceState maintenanceState) {
    final mileages = [
      ...maintenanceState.fuelRecords.map((e) => e.mileage),
      ...maintenanceState.serviceRecords.map((e) => e.mileage),
      ...maintenanceState.carWashRecords.map((e) => e.mileage),
      ...maintenanceState.tuningRecords.map((e) => e.mileage),
    ].whereType<int>();

    if (mileages.isEmpty) return 0;

    return mileages.reduce((a, b) => a > b ? a : b);
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
      final date = f.date;
      if (date.year != year || date.month != month) continue;
      total += f.cost;
      categoryTotals[ExpenseCategory.fuel] = (categoryTotals[ExpenseCategory.fuel] ?? 0) + f.cost;
    }

    for (final c in carWashRecords) {
      final date = c.date;
      if (date.year != year || date.month != month) continue;
      total += c.amount;
      categoryTotals[ExpenseCategory.other] = (categoryTotals[ExpenseCategory.other] ?? 0) + c.amount;
    }

    for (final t in tuningRecords) {
      final date = t.date;
      if (date.year != year || date.month != month) continue;
      total += t.cost;
      categoryTotals[ExpenseCategory.tuning] = (categoryTotals[ExpenseCategory.tuning] ?? 0) + t.cost;
    }

    final monthLabel = _monthName(month);

    return MonthlyExpenseStats(monthLabel: "$monthLabel $year", total: total, categoryTotals: categoryTotals);
  }

  String _monthName(int month) {
    const months = ["Січ", "Лют", "Бер", "Квіт", "Трав", "Черв", "Лип", "Серп", "Верес", "Жовт", "Лист", "Груд"];
    return months[month - 1];
  }

  double calculateAverageFuelConsumption(List<FuelRecord> records) {
    if (records.length < 2) return 0.0;

    final sorted = List<FuelRecord>.from(records)..sort((a, b) => a.mileage.compareTo(b.mileage));

    final firstMileage = sorted.first.mileage;
    final lastMileage = sorted.last.mileage;
    final distance = (lastMileage - firstMileage).toDouble();

    if (distance <= 0) return 0.0;

    final totalLiters = sorted.fold<double>(0.0, (sum, r) => sum + (r.volume));

    final avgPer100km = totalLiters / distance * 100.0;

    if (avgPer100km.isNaN || avgPer100km.isInfinite) return 0.0;

    return avgPer100km;
  }
}
