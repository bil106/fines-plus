// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:core_data/core_data.dart';
import 'package:core_repository/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'maintenance_state.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final ExpenseRepository expenseRepository;
  final CarInfoLocalDataSource localDataSource;
  MaintenanceCubit({
    required this.expenseRepository,
    required this.localDataSource,
  }) : super(const MaintenanceState()) {
    init();
  }
  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await _loadAllFromPrefs();
    await syncExpensesFromFirestore();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> addRecord<T>({
    required T record,
    required String prefsKey,
    required ExpenseCategory category,
    required Expense Function(String userId) mapper,
  }) async {
    final currentList = state.getListByType<T>();
    final updatedList = List<T>.from(currentList);

    if (!_containsRecord(updatedList, record)) {
      updatedList.add(record);

      emit(state.copyWithByType<T>(updatedList));

      await _saveRecordsToPrefs(prefsKey, updatedList);

      final car = await localDataSource.getCarInfo();
      final userId = FirebaseAuth.instance.currentUser!.uid;
      try {
        await expenseRepository.addExpense(
          carNumber: car.carNumber,
          expense: mapper(userId),
        );
        debugPrint("✅ ${category.name} record saved to Firestore");
      } catch (e) {
        debugPrint("❌ Failed to save ${category.name} record: $e");
      }
    } else {
      debugPrint("ℹ️ ${category.name} record already exists, skipping");
    }
  }

  bool _containsRecord<T>(List<T> list, T record) {
    final recordJson = (record as dynamic).toJson();
    return list.any((e) => mapEquals((e as dynamic).toJson(), recordJson));
  }

  Future<void> _loadAllFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      serviceRecords:
          _loadListFromPrefs<ServiceRecord>(prefs, 'service_records', (json) => ServiceRecord.fromJson(json)),
      fuelRecords: _loadListFromPrefs<FuelRecord>(prefs, 'fuel_records', (json) => FuelRecord.fromJson(json)),
      tuningRecords: _loadListFromPrefs<TuningRecord>(prefs, 'tuning_records', (json) => TuningRecord.fromJson(json)),
      carWashRecords:
          _loadListFromPrefs<CarWashRecord>(prefs, 'car_wash_records', (json) => CarWashRecord.fromJson(json)),
    ));
  }

  List<T> _loadListFromPrefs<T>(SharedPreferences prefs, String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    return (jsonDecode(jsonString) as List).map((e) => fromJson(e)).toList();
  }

  Future<void> _saveRecordsToPrefs<T>(String key, List<T> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((r) => (r as dynamic).toJson() ?? {}).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<void> syncExpensesFromFirestore() async {
    emit(state.copyWith(isLoading: true));
    try {
      final car = await localDataSource.getCarInfo();
      if (car.carNumber.isEmpty) return emit(state.copyWith(isLoading: false));

      final expenses = await expenseRepository.getExpensesOnce(carNumber: car.carNumber);

      final serviceRecords = <ServiceRecord>[];
      final fuelRecords = <FuelRecord>[];
      final tuningRecords = <TuningRecord>[];
      final carWashRecords = <CarWashRecord>[];

      for (final exp in expenses) {
        switch (exp.category) {
          case ExpenseCategory.service:
            serviceRecords.add(ServiceRecord.fromExpense(exp));
            break;
          case ExpenseCategory.fuel:
            fuelRecords.add(FuelRecord.fromExpense(exp));
            break;
          case ExpenseCategory.tuning:
            tuningRecords.add(TuningRecord.fromExpense(exp));
            break;
          case ExpenseCategory.carWash:
            carWashRecords.add(CarWashRecord.fromExpense(exp));
            break;
          default:
            break;
        }
      }

      emit(state.copyWith(
        serviceRecords: _mergeRecords(state.serviceRecords, serviceRecords),
        fuelRecords: _mergeRecords(state.fuelRecords, fuelRecords),
        tuningRecords: _mergeRecords(state.tuningRecords, tuningRecords),
        carWashRecords: _mergeRecords(state.carWashRecords, carWashRecords),
        isLoading: false,
      ));

      await _saveRecordsToPrefs('service_records', state.serviceRecords);
      await _saveRecordsToPrefs('fuel_records', state.fuelRecords);
      await _saveRecordsToPrefs('tuning_records', state.tuningRecords);
      await _saveRecordsToPrefs('car_wash_records', state.carWashRecords);
    } catch (e) {
      debugPrint("❌ [SYNC] Error: $e");
      emit(state.copyWith(isLoading: false));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  List<T> _mergeRecords<T>(List<T> local, List<T> fromFirestore) {
    final merged = List<T>.from(local);
    for (var record in fromFirestore) {
      if (!_containsRecord(merged, record)) {
        merged.add(record);
      }
    }
    return merged;
  }

  Future<void> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('service_records');
    if (jsonString != null) {
      final records = (jsonDecode(jsonString) as List).map((e) => ServiceRecord.fromJson(e)).toList();
      emit(state.copyWith(serviceRecords: records));
      await _saveAllToFirestore(records, ExpenseCategory.service, (r, uid) => r.toExpense(uid));
    }
  }

  Future<void> loadFuelRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('fuel_records');
    if (jsonString != null) {
      final records = (jsonDecode(jsonString) as List).map((e) => FuelRecord.fromJson(e)).toList();
      emit(state.copyWith(fuelRecords: records));
      await _saveAllToFirestore(records, ExpenseCategory.fuel, (r, uid) => r.toExpense(uid));
    }
  }

  Future<void> loadCarWashRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('car_wash_records');
    if (jsonString != null) {
      final records = (jsonDecode(jsonString) as List).map((e) => CarWashRecord.fromJson(e)).toList();
      emit(state.copyWith(carWashRecords: records));
      await _saveAllToFirestore(records, ExpenseCategory.carWash, (r, uid) => r.toExpense(uid));
    }
  }

  Future<void> loadTuningRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tuning_records');
    if (jsonString != null) {
      final records = (jsonDecode(jsonString) as List).map((e) => TuningRecord.fromJson(e)).toList();
      emit(state.copyWith(tuningRecords: records));
      await _saveAllToFirestore(records, ExpenseCategory.tuning, (r, uid) => r.toExpense(uid));
    }
  }

  Future<void> loadServiceRecords() async {
    await _loadAndSyncRecords<ServiceRecord>(
      prefsKey: 'service_records',
      currentList: state.serviceRecords,
      category: ExpenseCategory.service,
      fromJson: (json) => ServiceRecord.fromJson(json),
    );
  }

  Future<void> addExpenseRecord<T>({
    required T record,
    required String prefsKey,
    required List<T> currentList,
    required ExpenseCategory category,
    required Expense Function(String userId) mapper,
  }) async {
    final updated = List<T>.from(currentList)..add(record);
    if (T == ServiceRecord) {
      emit(state.copyWith(serviceRecords: updated.cast<ServiceRecord>()));
    } else if (T == FuelRecord) {
      emit(state.copyWith(fuelRecords: updated.cast<FuelRecord>()));
    } else if (T == TuningRecord) {
      emit(state.copyWith(tuningRecords: updated.cast<TuningRecord>()));
    } else if (T == CarWashRecord) {
      emit(state.copyWith(carWashRecords: updated.cast<CarWashRecord>()));
    }

    await _saveRecordsToPrefs(prefsKey, updated);

    final car = await localDataSource.getCarInfo();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await expenseRepository.addExpense(
        carNumber: car.carNumber,
        expense: mapper(userId),
      );
      debugPrint("✅ ${category.name} record saved to Firestore");
    } catch (e) {
      debugPrint("❌ Failed to save ${category.name} record: $e");
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

    final car = await localDataSource.getCarInfo();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    for (final record in records) {
      final expense = record.toExpense(userId);
      try {
        await expenseRepository.addExpense(
          carNumber: car.carNumber,
          expense: expense,
        );
        debugPrint("✅ Service record saved to Firestore");
      } catch (e) {
        debugPrint("❌ Failed to save ServiceRecord: $e");
      }
    }
  }

  Future<void> addFuelRecord(FuelRecord record) async {
    final updated = List<FuelRecord>.from(state.fuelRecords)..add(record);
    emit(state.copyWith(fuelRecords: updated));
    await saveFuelRecords();

    final car = await localDataSource.getCarInfo();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final expense = record.toExpense(userId);

    try {
      await expenseRepository.addExpense(
        carNumber: car.carNumber,
        expense: expense,
      );
      debugPrint("✅ Fuel record saved to Firestore");
    } catch (e) {
      debugPrint("❌ Failed to save fuel record: $e");
    }
  }

  Future<void> addCarWashRecord(CarWashRecord record) async {
    final updated = List<CarWashRecord>.from(state.carWashRecords)..add(record);
    emit(state.copyWith(carWashRecords: updated));
    await saveCarWashRecords();

    final car = await localDataSource.getCarInfo();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final expense = record.toExpense(userId);

    try {
      await expenseRepository.addExpense(
        carNumber: car.carNumber,
        expense: expense,
      );
      debugPrint("✅ CarWashRecord saved to Firestore");
    } catch (e) {
      debugPrint("❌ Failed to save CarWashRecord: $e");
    }
  }

  Future<void> addServiceRecord(ServiceRecord record) async {
    final updated = List<ServiceRecord>.from(state.serviceRecords)..add(record);
    emit(state.copyWith(serviceRecords: updated));
    await saveServiceRecords();

    final car = await localDataSource.getCarInfo();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final expense = record.toExpense(userId);

    try {
      await expenseRepository.addExpense(
        carNumber: car.carNumber,
        expense: expense,
      );
      debugPrint("✅ Service record saved to Firestore");
    } catch (e) {
      debugPrint("❌ Service to save fuel record: $e");
    }
  }

  Future<void> addTuningRecordsList(List<TuningRecord> records) async {
    final updated = List<TuningRecord>.from(state.tuningRecords)..addAll(records);
    emit(state.copyWith(tuningRecords: updated));
    await _saveRecordsToPrefs('tuning_records', updated);

    final car = await localDataSource.getCarInfo();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    for (final record in records) {
      final expense = record.toExpense(userId);
      try {
        await expenseRepository.addExpense(
          carNumber: car.carNumber,
          expense: expense,
        );
      } catch (e) {
        debugPrint("❌ Failed to save TuningRecord: $e");
      }
    }
  }

  Future<void> saveFuelRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.fuelRecords.map((r) => r.toJson()).toList();
    await prefs.setString('fuel_records', jsonEncode(jsonList));
  }

  Future<void> saveCarWashRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.carWashRecords.map((r) => r.toJson()).toList();
    await prefs.setString('car_wash_records', jsonEncode(jsonList));
  }

  Future<void> saveServiceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.serviceRecords.map((r) => r.toJson()).toList();
    await prefs.setString('service_records', jsonEncode(jsonList));
  }

  Future<void> saveTuningRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.tuningRecords.map((r) => r.toJson()).toList();
    await prefs.setString('tuning_records', jsonEncode(jsonList));
  }

  Future<void> addTuningRecord(TuningRecord record) async {
    await addExpenseRecord<TuningRecord>(
      record: record,
      prefsKey: 'tuning_records',
      currentList: state.tuningRecords,
      category: ExpenseCategory.tuning,
      mapper: (uid) => record.toExpense(uid),
    );
  }

  Future<void> deleteExpensesByCategory(ExpenseCategory category) async {
    try {
      emit(state.copyWith(isLoading: true));

      final car = await localDataSource.getCarInfo();
      final prefs = await SharedPreferences.getInstance();

      switch (category) {
        case ExpenseCategory.service:
          await prefs.remove('service_records');
          emit(state.copyWith(serviceRecords: []));
          break;
        case ExpenseCategory.fuel:
          await prefs.remove('fuel_records');
          emit(state.copyWith(fuelRecords: []));
          break;
        case ExpenseCategory.tuning:
          await prefs.remove('tuning_records');
          emit(state.copyWith(tuningRecords: []));
          break;
        case ExpenseCategory.carWash:
          await prefs.remove('car_wash_records');
          emit(state.copyWith(carWashRecords: []));
          break;
        case ExpenseCategory.other:
          throw UnimplementedError();
      }

      await expenseRepository.deleteExpensesByCategory(
        carNumber: car.carNumber,
        category: category.name,
      );

      debugPrint("🧹 All expenses in this category have been removed ${category.name}");
    } catch (e) {
      debugPrint("❌ Error deleting category: $e");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteExpensesByCategoryOrAll(ExpenseCategory? category) async {
    try {
      emit(state.copyWith(isLoading: true));
      final car = await localDataSource.getCarInfo();
      final prefs = await SharedPreferences.getInstance();

      if (category == null) {
        await expenseRepository.deleteAllExpenses(carNumber: car.carNumber);
        await prefs.remove('service_records');
        await prefs.remove('fuel_records');
        await prefs.remove('tuning_records');
        await prefs.remove('car_wash_records');

        emit(state.copyWith(
          serviceRecords: [],
          fuelRecords: [],
          tuningRecords: [],
          carWashRecords: [],
        ));
        debugPrint('🧹 All expenses have been removed for ${car.carNumber}');
      } else {
        await expenseRepository.deleteExpensesByCategory(
          carNumber: car.carNumber,
          category: category.name,
        );

        switch (category) {
          case ExpenseCategory.service:
            await prefs.remove('service_records');
            emit(state.copyWith(serviceRecords: []));
            break;
          case ExpenseCategory.fuel:
            await prefs.remove('fuel_records');
            emit(state.copyWith(fuelRecords: []));
            break;
          case ExpenseCategory.tuning:
            await prefs.remove('tuning_records');
            emit(state.copyWith(tuningRecords: []));
            break;
          case ExpenseCategory.carWash:
            await prefs.remove('car_wash_records');
            emit(state.copyWith(carWashRecords: []));
            break;
          case ExpenseCategory.other:
            throw UnimplementedError();
        }

        debugPrint('🧹 All expenses in this category have been removed ${category.name}');
      }
    } catch (e) {
      debugPrint('❌Error deleting expenses: $e');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteSingleExpense(ExpenseCategory category, String expenseId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final car = await localDataSource.getCarInfo();
      final prefs = await SharedPreferences.getInstance();

      await expenseRepository.deleteExpense(
        carNumber: car.carNumber,
        expenseId: expenseId,
      );

      switch (category) {
        case ExpenseCategory.service:
          final updated = state.serviceRecords.where((r) => r.id != expenseId).toList();
          emit(state.copyWith(serviceRecords: updated));
          await prefs.setString('service_records', jsonEncode(updated.map((e) => e.toJson()).toList()));
          break;

        case ExpenseCategory.fuel:
          final updated = state.fuelRecords.where((r) => r.id != expenseId).toList();
          emit(state.copyWith(fuelRecords: updated));
          await prefs.setString('fuel_records', jsonEncode(updated.map((e) => e.toJson()).toList()));
          break;

        case ExpenseCategory.tuning:
          final updated = state.tuningRecords.where((r) => r.id != expenseId).toList();
          emit(state.copyWith(tuningRecords: updated));
          await prefs.setString('tuning_records', jsonEncode(updated.map((e) => e.toJson()).toList()));
          break;

        case ExpenseCategory.carWash:
          final updated = state.carWashRecords.where((r) => r.id != expenseId).toList();
          emit(state.copyWith(carWashRecords: updated));
          await prefs.setString('car_wash_records', jsonEncode(updated.map((e) => e.toJson()).toList()));
          break;

        default:
          break;
      }

      debugPrint('✅ The expense has been successfully removed $expenseId (${category.name})');
    } catch (e) {
      debugPrint('❌ Error while deleting: $e');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteAllExpenses() async {
    try {
      emit(state.copyWith(isLoading: true));

      final car = await localDataSource.getCarInfo();
      final prefs = await SharedPreferences.getInstance();

      await expenseRepository.deleteAllExpenses(carNumber: car.carNumber);

      await prefs.remove('service_records');
      await prefs.remove('tuning_records');
      await prefs.remove('fuel_records');
      await prefs.remove('car_wash_records');

      emit(state.copyWith(
        serviceRecords: [],
        tuningRecords: [],
        fuelRecords: [],
        carWashRecords: [],
        isLoading: false,
      ));

      debugPrint("🧹All expenses removed for ${car.carNumber}");
    } catch (e, st) {
      debugPrint("❌ deleteAllExpenses error: $e\n$st");
      emit(state.copyWith(isLoading: false));
    }
  }

  void toggleMenu() {
    emit(state.copyWith(isMenuOpen: !state.isMenuOpen));
  }

  void closeMenu() {
    emit(state.copyWith(isMenuOpen: false));
  }

  void clearAllRecords() {
    emit(const MaintenanceState(
      serviceRecords: [],
      tuningRecords: [],
      fuelRecords: [],
      carWashRecords: [],
    ));
  }
}

extension MileageCalculations on MaintenanceCubit {
  Map<String, int> getMonthlyMileage() {
    final allRecords = [
      ...state.serviceRecords.map((r) => {
            'date': DateFormat('dd.MM.yyyy').parse(r.date),
            'mileage': r.mileage,
          }),
      ...state.fuelRecords.map((r) => {
            'date': DateFormat('dd.MM.yyyy').parse(r.date),
            'mileage': r.mileage,
          }),
      ...state.carWashRecords.map((r) => {
            'date': DateFormat('dd.MM.yyyy').parse(r.date),
            'mileage': r.mileage,
          }),
      ...state.tuningRecords.map((r) => {
            'date': DateFormat('dd.MM.yyyy').parse(r.date),
            'mileage': r.mileage,
          }),
    ];

    if (allRecords.isEmpty) return {};

    final Map<String, List<int>> months = {};
    for (final r in allRecords) {
      final d = r['date'] as DateTime;
      final key = "${d.year}-${d.month.toString().padLeft(2, '0')}";
      months.putIfAbsent(key, () => []);
      months[key]!.add(r['mileage'] as int);
    }

    final Map<String, int> result = {};
    months.forEach((key, mileages) {
      mileages.sort();
      result[key] = mileages.last - mileages.first;
    });

    return result;
  }

  int getCurrentMonthMileage(DateTime now) {
    final monthly = getMonthlyMileage();
    final key = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final current = monthly[key] ?? 0;

    final past = monthly.entries.where((e) => e.key.compareTo(key) < 0).fold(0, (sum, e) => sum + e.value);

    return past + current;
  }

  int getAverageMileage() {
    final monthly = getMonthlyMileage();

    if (monthly.isEmpty) return 0;

    final total = monthly.values.fold(0, (sum, m) => sum + m);
    return total ~/ monthly.length;
  }

  Future<void> _loadAndSyncRecords<T>({
    required String prefsKey,
    required List<T> currentList,
    required ExpenseCategory category,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(prefsKey);
    if (jsonString == null) return;

    List<T> updatedList = List<T>.from(currentList);

    final records = (jsonDecode(jsonString) as List).map((e) => fromJson(e)).toList();

    for (var record in records) {
      await addExpenseRecord<T>(
        record: record,
        prefsKey: prefsKey,
        currentList: updatedList,
        category: category,
        mapper: (uid) {
          if (record is ServiceRecord) return record.toExpense(uid);
          if (record is FuelRecord) return record.toExpense(uid);
          if (record is TuningRecord) return record.toExpense(uid);
          if (record is CarWashRecord) return record.toExpense(uid);
          throw UnimplementedError();
        },
      );

      updatedList.add(record);
    }
  }

  Future<void> _saveAllToFirestore<T>(
    List<T> records,
    ExpenseCategory category,
    Expense Function(T record, String userId) mapper,
  ) async {
    final car = await localDataSource.getCarInfo();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    for (var r in records) {
      try {
        await expenseRepository.addExpense(
          carNumber: car.carNumber,
          expense: mapper(r, userId),
        );
      } catch (e) {
        debugPrint("❌ Failed to save ${category.name} record: $e");
      }
    }
  }
}

extension MaintenanceStateUpdater on MaintenanceState {
  MaintenanceState copyWithByType<T>(List<T> updatedList) {
    if (T == ServiceRecord) return copyWith(serviceRecords: updatedList.cast<ServiceRecord>());
    if (T == FuelRecord) return copyWith(fuelRecords: updatedList.cast<FuelRecord>());
    if (T == TuningRecord) return copyWith(tuningRecords: updatedList.cast<TuningRecord>());
    if (T == CarWashRecord) return copyWith(carWashRecords: updatedList.cast<CarWashRecord>());
    return this;
  }
}

extension MaintenanceStateExtension on MaintenanceState {
  List<T> getListByType<T>() {
    if (T == ServiceRecord) return serviceRecords as List<T>;
    if (T == FuelRecord) return fuelRecords as List<T>;
    if (T == TuningRecord) return tuningRecords as List<T>;
    if (T == CarWashRecord) return carWashRecords as List<T>;
    return [];
  }
}
