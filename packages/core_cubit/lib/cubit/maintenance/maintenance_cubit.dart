
import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
