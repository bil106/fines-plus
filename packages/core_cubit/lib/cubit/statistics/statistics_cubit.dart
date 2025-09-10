import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:core_cubit/cubit/statistics/statistics_state.dart';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/widgets/extensions/monthly_expense_stats.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit() : super(StatisticsState.initial());


  Future<void> loadAll() async {
    emit(state.copyWith(loading: true));

    final mileageRecords = await _loadMileageRecords();
    final serviceRecords = await _loadServiceRecords();
    final fuelRecords = await _loadFuelRecords();

    final now = DateTime.now();
    final expenseStats = _calculateMonthlyStats(
      serviceRecords: serviceRecords,
      fuelRecords: fuelRecords,
      year: now.year,
      month: now.month,
    );

    emit(state.copyWith(
      loading: false,
      mileageRecords: mileageRecords,
      serviceRecords: serviceRecords,
      fuelRecords: fuelRecords,
      expenseStats: expenseStats,
    ));
  }

  /// Добавление пробега
  Future<void> addMileage(MileageRecord record) async {
    final updatedRecords = List<MileageRecord>.from(state.mileageRecords);
    updatedRecords.removeWhere((r) => r.month.year == record.month.year && r.month.month == record.month.month);
    updatedRecords.add(record);

    await _saveMileageRecords(updatedRecords);

    emit(state.copyWith(mileageRecords: updatedRecords));
  }

  /// --- PRIVATE METHODS ---

  Future<List<MileageRecord>> _loadMileageRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('mileage_records');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => MileageRecord.fromJson(e)).toList();
  }

  Future<void> _saveMileageRecords(List<MileageRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((e) => e.toJson()).toList();
    await prefs.setString('mileage_records', jsonEncode(jsonList));
  }

  Future<List<ServiceRecord>> _loadServiceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('service_records');
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => ServiceRecord.fromJson(e)).toList();
  }

  Future<List<FuelRecord>> _loadFuelRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('fuel_records');
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => FuelRecord.fromJson(e)).toList();
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
        return DateFormat('d.M.yyyy').parse(dateStr);
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
