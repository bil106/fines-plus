import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'maintenance_state.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  MaintenanceCubit() : super(const MaintenanceState()) {
    loadRecords();
    loadFuelRecords();
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('service_records');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final records = jsonList.map((e) => ServiceRecord.fromJson(e)).toList();
      emit(state.copyWith(serviceRecords: records));
    }
  }

  Future<void> saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.serviceRecords.map((r) => r.toJson()).toList();
    await prefs.setString('service_records', jsonEncode(jsonList));
  }

  Future<void> addServiceRecords(List<ServiceRecord> records) async {
    final updated = List<ServiceRecord>.from(state.serviceRecords)..addAll(records);
    emit(state.copyWith(serviceRecords: updated));
    await saveRecords();
  }

  Future<void> loadFuelRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('fuel_records');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final records = jsonList.map((e) => FuelRecord.fromJson(e)).toList();
      emit(state.copyWith(fuelRecords: records));
    }
  }

  Future<void> saveFuelRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.fuelRecords.map((r) => r.toJson()).toList();
    await prefs.setString('fuel_records', jsonEncode(jsonList));
  }

  Future<void> addFuelRecord(FuelRecord record) async {
    final updated = List<FuelRecord>.from(state.fuelRecords)..add(record);
    emit(state.copyWith(fuelRecords: updated));
    await saveFuelRecords();
  }

  void toggleMenu() {
    emit(state.copyWith(isMenuOpen: !state.isMenuOpen));
  }

  void closeMenu() {
    emit(state.copyWith(isMenuOpen: false));
  }
}
extension MileageCalculations on MaintenanceCubit {

  int getCurrentMonthMileage(DateTime now) {
    final allRecords = [
      ...state.serviceRecords.map((r) => {
        'date': DateFormat('dd.MM.yyyy').parse(r.date),
        'mileage': r.mileage
      }),
      ...state.fuelRecords.map((r) => {
        'date': DateFormat('dd.MM.yyyy').parse(r.date),
        'mileage': r.mileage
      }),
    ];

    final monthRecords = allRecords.where((r) {
      final d = r['date'] as DateTime;
      return d.year == now.year && d.month == now.month;
    }).toList();

    if (monthRecords.isEmpty) return 0;

    monthRecords.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return monthRecords.last['mileage'] as int;
  }



  int getAverageMileage() {
    final allRecords = [
      ...state.serviceRecords.map((r) => {'date': DateFormat('dd.MM.yyyy').parse(r.date), 'mileage': r.mileage}),
      ...state.fuelRecords.map((r) => {'date': DateFormat('dd.MM.yyyy').parse(r.date), 'mileage': r.mileage}),
    ];

    if (allRecords.isEmpty) return 0;

    final Map<String, List<int>> months = {};
    for (final r in allRecords) {
      final d = r['date'] as DateTime;
      final key = "${d.year}-${d.month}";
      months.putIfAbsent(key, () => []);
      months[key]!.add(r['mileage'] as int);
    }

    final monthMileages = months.values.map((mileages) {
      mileages.sort();
      return mileages.last - mileages.first;
    }).toList();

    final total = monthMileages.fold(0, (sum, m) => sum + m);
    return monthMileages.isNotEmpty ? total ~/ monthMileages.length : 0;
  }
}
