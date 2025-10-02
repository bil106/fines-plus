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

    final expenses = _calculateAllMonthlyStats(
      serviceRecords: maintenanceState.serviceRecords,
      fuelRecords: maintenanceState.fuelRecords,
      carWashRecords: maintenanceState.carWashRecords,
      tuningRecords: maintenanceState.tuningRecords,
    );

    emit(
      state.copyWith(
        loading: false,
        currentMonthMileage: currentMonthMileage,
        averageMileage: averageMileage,
        expenses: expenses,
      ),
    );
  }


  @override
  Future<void> close() {
    maintenanceSub.cancel();
    return super.close();
  }

  List<MonthlyExpenseStats> _calculateAllMonthlyStats({
    required List<ServiceRecord> serviceRecords,
    required List<FuelRecord> fuelRecords,
    required List<CarWashRecord> carWashRecords,
    required List<TuningRecord> tuningRecords,
  }) {
  
    final allDates = [
      ...serviceRecords.map((r) => DateFormat('dd.MM.yyyy').parse(r.date)),
      ...fuelRecords.map((r) => DateFormat('dd.MM.yyyy').parse(r.date)),
      ...carWashRecords.map((r) => DateFormat('dd.MM.yyyy').parse(r.date)),
      ...tuningRecords.map((r) => DateFormat('dd.MM.yyyy').parse(r.date)),
    ];

    if (allDates.isEmpty) return [];


    final grouped = <String, List<dynamic>>{};
    void addRecord(DateTime d, dynamic r) {
      final key = "${d.year}-${d.month}";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(r);
    }

    for (final s in serviceRecords) {
      final d = DateFormat('dd.MM.yyyy').parse(s.date);
      addRecord(d, s);
    }
    for (final f in fuelRecords) {
      final d = DateFormat('dd.MM.yyyy').parse(f.date);
      addRecord(d, f);
    }
    for (final c in carWashRecords) {
      final d = DateFormat('dd.MM.yyyy').parse(c.date);
      addRecord(d, c);
    }
    for (final t in tuningRecords) {
      final d = DateFormat('dd.MM.yyyy').parse(t.date);
      addRecord(d, t);
    }

    final stats = <MonthlyExpenseStats>[];
    grouped.forEach((key, records) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      stats.add(_calculateMonthlyStats(
        serviceRecords: serviceRecords,
        fuelRecords: fuelRecords,
        carWashRecords: carWashRecords,
        tuningRecords: tuningRecords,
        year: year,
        month: month,
      ));
    });


    stats.sort((a, b) => a.monthLabel.compareTo(b.monthLabel));
    return stats;
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
      final date = parseDate(f.date);
      if (date.year != year || date.month != month) continue;
      total += f.cost;
      categoryTotals[ExpenseCategory.fuel] = (categoryTotals[ExpenseCategory.fuel] ?? 0) + f.cost;
    }

    for (final c in carWashRecords) {
      final date = parseDate(c.date);
      if (date.year != year || date.month != month) continue;
      total += c.cost;
      categoryTotals[ExpenseCategory.other] = (categoryTotals[ExpenseCategory.other] ?? 0) + c.cost;
    }

    for (final t in tuningRecords) {
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
  Map<ExpenseCategory, double> getTotalCategoryExpenses() {
    final totals = <ExpenseCategory, double>{
      ExpenseCategory.fuel: 0,
      ExpenseCategory.service: 0,
      ExpenseCategory.tuning: 0,
      ExpenseCategory.other: 0,
    };

    for (final stat in state.expenses) {
      stat.categoryTotals.forEach((key, value) {
        totals[key] = (totals[key] ?? 0) + value;
      });
    }

    return totals;
  }

}
extension TotalCategoryExpenses on StatisticsState {
  Map<ExpenseCategory, double> getTotalCategoryExpenses() {
    final totals = <ExpenseCategory, double>{
      ExpenseCategory.fuel: 0,
      ExpenseCategory.service: 0,
      ExpenseCategory.tuning: 0,
      ExpenseCategory.other: 0,
    };

    for (final stat in expenses) {
      stat.categoryTotals.forEach((key, value) {
        totals[key] = (totals[key] ?? 0) + value;
      });
    }

    return totals;
  }

  double getTotalExpenses() {
    return getTotalCategoryExpenses().values.fold(0, (sum, v) => sum + v);
  }
}
