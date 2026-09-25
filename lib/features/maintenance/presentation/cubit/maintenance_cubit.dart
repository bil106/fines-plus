// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/insurance_record.dart';
import 'package:fines_plus/features/expenses/data/models/other_expense_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_local_data_source.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'maintenance_state.dart';
import 'dart:async';
import 'package:bloc/bloc.dart';

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final ExpenseRepository expenseRepository;
  final CarInfoLocalDataSource localDataSource;
  final CarCubit carCubit;
  late final StreamSubscription _carSub;
  StreamSubscription<List<Expense>>? _expensesSub;
  late String _activeCarId;

  MaintenanceCubit({required this.expenseRepository, required this.localDataSource, required this.carCubit})
    : super(const MaintenanceState()) {
    _activeCarId = carCubit.state.carId;
    _carSub = carCubit.stream.listen((carState) {
      _onCarChanged(carState.carId);
    });
    init();
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await _loadAllFromPrefs();
    _listenToExpenses(_activeCarId);
    emit(state.copyWith(isLoading: false));
  }

  /// [localDataSource] reflects the NEW car by the time this fires (CarCubit
  /// persists it before emitting), so comparing against local storage here
  /// always agreed with [newCarId] and made this a no-op — records from the
  /// previous car were never cleared on a real switch. Track the previously
  /// active id ourselves instead.
  Future<void> _onCarChanged(String newCarId) async {
    if (newCarId == _activeCarId) return;
    _activeCarId = newCarId;

    try {
      emit(state.copyWith(isLoading: true));
      clearAllRecords();
      _listenToExpenses(newCarId);
    } catch (e, st) {
      debugPrint('MaintenanceCubit _onCarChanged error: $e\n$st');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Keeps records live-synced with Firestore instead of only refreshing on
  /// an explicit [syncExpensesFromFirestore] call (e.g. opening the
  /// maintenance screen) — an expense added on another device now reaches
  /// this one, and the Home stats it feeds, the moment Firestore pushes it.
  void _listenToExpenses(String carId) {
    _expensesSub?.cancel();
    if (carId.isEmpty) return;

    _expensesSub = expenseRepository.watchExpenses(carNumber: carId).listen(
      (expenses) {
        final serviceRecords = <ServiceRecord>[];
        final fuelRecords = <FuelRecord>[];
        final tuningRecords = <TuningRecord>[];
        final carWashRecords = <CarWashRecord>[];
        final insuranceRecords = <InsuranceRecord>[];
        final otherRecords = <OtherExpenseRecord>[];

        for (final exp in expenses) {
          switch (exp.category) {
            case ExpenseCategory.service:
              serviceRecords.add(ServiceRecord.fromExpense(exp));
              break;
            case ExpenseCategory.fuel:
              fuelRecords.add(FuelRecord.fromExpense(exp, currency: ''));
              break;
            case ExpenseCategory.tuning:
              tuningRecords.add(TuningRecord.fromExpense(exp));
              break;
            case ExpenseCategory.carWash:
              carWashRecords.add(CarWashRecord.fromExpense(exp));
              break;
            case ExpenseCategory.insurance:
              insuranceRecords.add(InsuranceRecord.fromExpense(exp));
              break;
            case ExpenseCategory.other:
              otherRecords.add(OtherExpenseRecord.fromExpense(exp));
              break;
          }
        }

        emit(
          state.copyWith(
            serviceRecords: serviceRecords,
            fuelRecords: fuelRecords,
            tuningRecords: tuningRecords,
            carWashRecords: carWashRecords,
            insuranceRecords: insuranceRecords,
            otherRecords: otherRecords,
            isLoading: false,
          ),
        );

        _saveRecordsToPrefs('service_records', serviceRecords);
        _saveRecordsToPrefs('fuel_records', fuelRecords);
        _saveRecordsToPrefs('tuning_records', tuningRecords);
        _saveRecordsToPrefs('car_wash_records', carWashRecords);
        _saveRecordsToPrefs('insurance_records', insuranceRecords);
        _saveRecordsToPrefs('other_records', otherRecords);
      },
      onError: (e) => debugPrint('MaintenanceCubit expenses stream error: $e'),
    );
  }

  Future<void> addRecord<T>({
    required T record,
    required String prefsKey,
    required ExpenseCategory category,
    required Expense Function(String ownerId) mapper,
  }) async {
    final currentList = state.getListByType<T>();
    final updatedList = List<T>.from(currentList);

    if (!_containsRecord(updatedList, record)) {
      updatedList.add(record);

      emit(state.copyWithByType<T>(updatedList));

      await _saveRecordsToPrefs(prefsKey, updatedList);

      final car = await localDataSource.getCarInfo();
      final ownerId = FirebaseAuth.instance.currentUser!.uid;
      try {
        await expenseRepository.addExpense(carNumber: car.carId, expense: mapper(ownerId));
        debugPrint("${category.name} record saved to Firestore");
      } catch (e) {
        debugPrint("Failed to save ${category.name} record: $e");
      }
    } else {
      debugPrint("ℹ${category.name} record already exists, skipping");
    }
  }

  bool _containsRecord<T>(List<T> list, T record) {
    final r = record as dynamic;

    if (r.id != null && r.id!.isNotEmpty) {
      return list.any((e) => (e as dynamic).id == r.id);
    }

    return list.any((e) {
      final eDyn = e as dynamic;
      return eDyn.date == r.date && eDyn.mileage == r.mileage && eDyn.amount == r.amount && eDyn.comment == r.comment;
    });
  }

  Future<void> _loadAllFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    emit(
      state.copyWith(
        serviceRecords: _loadListFromPrefs<ServiceRecord>(
          prefs,
          'service_records',
          (json) => ServiceRecord.fromJson(json),
        ),
        fuelRecords: _loadListFromPrefs<FuelRecord>(prefs, 'fuel_records', (json) => FuelRecord.fromJson(json)),
        tuningRecords: _loadListFromPrefs<TuningRecord>(prefs, 'tuning_records', (json) => TuningRecord.fromJson(json)),
        carWashRecords: _loadListFromPrefs<CarWashRecord>(
          prefs,
          'car_wash_records',
          (json) => CarWashRecord.fromJson(json),
        ),
        insuranceRecords: _loadListFromPrefs<InsuranceRecord>(
          prefs,
          'insurance_records',
          (json) => InsuranceRecord.fromJson(json),
        ),
        otherRecords: _loadListFromPrefs<OtherExpenseRecord>(
          prefs,
          'other_records',
          (json) => OtherExpenseRecord.fromJson(json),
        ),
      ),
    );
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
      if (car.carId.isEmpty) return emit(state.copyWith(isLoading: false));

      final expenses = await expenseRepository.getExpensesOnce(carNumber: car.carId);

      final serviceRecords = <ServiceRecord>[];
      final fuelRecords = <FuelRecord>[];
      final tuningRecords = <TuningRecord>[];
      final carWashRecords = <CarWashRecord>[];
      final insuranceRecords = <InsuranceRecord>[];
      final otherRecords = <OtherExpenseRecord>[];

      for (final exp in expenses) {
        switch (exp.category) {
          case ExpenseCategory.service:
            serviceRecords.add(ServiceRecord.fromExpense(exp));
            break;
          case ExpenseCategory.fuel:
            fuelRecords.add(FuelRecord.fromExpense(exp, currency: ''));
            break;
          case ExpenseCategory.tuning:
            tuningRecords.add(TuningRecord.fromExpense(exp));
            break;
          case ExpenseCategory.carWash:
            carWashRecords.add(CarWashRecord.fromExpense(exp));
            break;
          case ExpenseCategory.insurance:
            insuranceRecords.add(InsuranceRecord.fromExpense(exp));
            break;
          case ExpenseCategory.other:
            otherRecords.add(OtherExpenseRecord.fromExpense(exp));
            break;
        }
      }

      emit(
        state.copyWith(
          serviceRecords: _mergeRecords(state.serviceRecords, serviceRecords),
          fuelRecords: _mergeRecords(state.fuelRecords, fuelRecords),
          tuningRecords: _mergeRecords(state.tuningRecords, tuningRecords),
          carWashRecords: _mergeRecords(state.carWashRecords, carWashRecords),
          insuranceRecords: _mergeRecords(state.insuranceRecords, insuranceRecords),
          otherRecords: _mergeRecords(state.otherRecords, otherRecords),
          isLoading: false,
        ),
      );

      await _saveRecordsToPrefs('service_records', state.serviceRecords);
      await _saveRecordsToPrefs('fuel_records', state.fuelRecords);
      await _saveRecordsToPrefs('tuning_records', state.tuningRecords);
      await _saveRecordsToPrefs('car_wash_records', state.carWashRecords);
      await _saveRecordsToPrefs('insurance_records', state.insuranceRecords);
      await _saveRecordsToPrefs('other_records', state.otherRecords);
    } catch (e) {
      debugPrint("[SYNC] Error: $e");
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
    required Expense Function(String ownerId) mapper,
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
    final ownerId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await expenseRepository.addExpense(carNumber: car.carId, expense: mapper(ownerId));
      debugPrint("${category.name} record saved to Firestore");
    } catch (e) {
      debugPrint("Failed to save ${category.name} record: $e");
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
    final ownerId = FirebaseAuth.instance.currentUser!.uid;

    for (final record in records) {
      final expense = record.toExpense(ownerId);
      try {
        await expenseRepository.addExpense(carNumber: car.carId, expense: expense);
        debugPrint("Service record saved to Firestore");
      } catch (e) {
        debugPrint("Failed to save ServiceRecord: $e");
      }
    }
  }

  /// Returns whether the record was saved, so the form can stay open (with
  /// the user's input intact) on failure instead of closing silently.
  ///
  /// "Saved" means written to the local Firestore cache: the server upload
  /// is not awaited, because with offline persistence that Future only
  /// completes once the server acknowledges - offline it would never
  /// complete and the form would hang. Firestore retries the upload itself.
  Future<bool> addFuelRecord(FuelRecord record) async {
    try {
      final car = await localDataSource.getCarInfo();
      final user = FirebaseAuth.instance.currentUser;
      if (car.carId.isEmpty || user == null) return false;

      final updated = List<FuelRecord>.from(state.fuelRecords)..add(record);
      emit(state.copyWith(fuelRecords: updated));
      await saveFuelRecords();

      unawaited(
        expenseRepository
            .addExpense(carNumber: car.carId, expense: record.toExpense(user.uid))
            .then<void>(
              (_) {},
              onError: (Object e, StackTrace s) =>
                  FirebaseCrashlytics.instance.recordError(e, s),
            ),
      );
      return true;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return false;
    }
  }

  Future<void> addInsuranceRecord(InsuranceRecord record) async {
    final updated = List<InsuranceRecord>.from(state.insuranceRecords)..add(record);
    emit(state.copyWith(insuranceRecords: updated));
    await saveInsuranceRecords();

    final car = await localDataSource.getCarInfo();
    final ownerId = FirebaseAuth.instance.currentUser!.uid;

    final expense = record.toExpense(ownerId);

    try {
      await expenseRepository.addExpense(carNumber: car.carId, expense: expense);
      debugPrint("Insurance record saved to Firestore");
    } catch (e) {
      debugPrint("Failed to save insurance record: $e");
    }
  }

  Future<void> addOtherRecord(OtherExpenseRecord record) async {
    final updated = List<OtherExpenseRecord>.from(state.otherRecords)..add(record);
    emit(state.copyWith(otherRecords: updated));
    await saveOtherRecords();

    final car = await localDataSource.getCarInfo();
    final ownerId = FirebaseAuth.instance.currentUser!.uid;

    final expense = record.toExpense(ownerId);

    try {
      await expenseRepository.addExpense(carNumber: car.carId, expense: expense);
      debugPrint("Other expense record saved to Firestore");
    } catch (e) {
      debugPrint("Failed to save other expense record: $e");
    }
  }

  Future<void> addCarWashRecord(CarWashRecord record) async {
    final updated = List<CarWashRecord>.from(state.carWashRecords)..add(record);
    emit(state.copyWith(carWashRecords: updated));
    await saveCarWashRecords();

    final car = await localDataSource.getCarInfo();
    if (car.carId.isEmpty) {
      debugPrint("Cannot save CarWashRecord: carNumber is empty");
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint("Cannot save CarWashRecord: user not signed in");
      return;
    }

    final expense = record.toExpense(currentUser.uid);

    try {
      await expenseRepository.addExpense(carNumber: car.carId, expense: expense);
      debugPrint("CarWashRecord saved to Firestore");
    } catch (e) {
      debugPrint("Failed to save CarWashRecord: $e");
    }
  }

  Future<void> addServiceRecord(ServiceRecord record) async {
    final updated = List<ServiceRecord>.from(state.serviceRecords)..add(record);
    emit(state.copyWith(serviceRecords: updated));
    await saveServiceRecords();

    final car = await localDataSource.getCarInfo();
    final ownerId = FirebaseAuth.instance.currentUser!.uid;

    final expense = record.toExpense(ownerId);

    try {
      await expenseRepository.addExpense(carNumber: car.carId, expense: expense);
      debugPrint("Service record saved to Firestore");
    } catch (e) {
      debugPrint("Service to save fuel record: $e");
    }
  }

  Future<void> addTuningRecordsList(List<TuningRecord> records) async {
    final updated = List<TuningRecord>.from(state.tuningRecords)..addAll(records);
    emit(state.copyWith(tuningRecords: updated));
    await _saveRecordsToPrefs('tuning_records', updated);

    final car = await localDataSource.getCarInfo();
    final ownerId = FirebaseAuth.instance.currentUser!.uid;

    for (final record in records) {
      final expense = record.toExpense(ownerId);
      try {
        await expenseRepository.addExpense(carNumber: car.carId, expense: expense);
      } catch (e) {
        debugPrint("Failed to save TuningRecord: $e");
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

  Future<void> saveInsuranceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.insuranceRecords.map((r) => r.toJson()).toList();
    await prefs.setString('insurance_records', jsonEncode(jsonList));
  }

  Future<void> saveOtherRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.otherRecords.map((r) => r.toJson()).toList();
    await prefs.setString('other_records', jsonEncode(jsonList));
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
        case ExpenseCategory.insurance:
          await prefs.remove('insurance_records');
          emit(state.copyWith(insuranceRecords: []));
          break;
        case ExpenseCategory.other:
          await prefs.remove('other_records');
          emit(state.copyWith(otherRecords: []));
          break;
      }

      await expenseRepository.deleteExpensesByCategory(carNumber: car.carId, category: category.name);

      debugPrint(" All expenses in this category have been removed ${category.name}");
    } catch (e) {
      debugPrint("Error deleting category: $e");
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
        await expenseRepository.deleteAllExpenses(carNumber: car.carId);
        await prefs.remove('service_records');
        await prefs.remove('fuel_records');
        await prefs.remove('tuning_records');
        await prefs.remove('car_wash_records');
        await prefs.remove('insurance_records');
        await prefs.remove('other_records');

        emit(
          state.copyWith(
            serviceRecords: [],
            fuelRecords: [],
            tuningRecords: [],
            carWashRecords: [],
            insuranceRecords: [],
            otherRecords: [],
          ),
        );
        debugPrint(' All expenses have been removed for ${car.carId}');
      } else {
        await expenseRepository.deleteExpensesByCategory(carNumber: car.carId, category: category.name);

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
          case ExpenseCategory.insurance:
            await prefs.remove('insurance_records');
            emit(state.copyWith(insuranceRecords: []));
            break;
          case ExpenseCategory.other:
            await prefs.remove('other_records');
            emit(state.copyWith(otherRecords: []));
            break;
        }

        debugPrint(' All expenses in this category have been removed ${category.name}');
      }
    } catch (e) {
      debugPrint('Error deleting expenses: $e');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteSingleExpense(ExpenseCategory category, String expenseId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final car = await localDataSource.getCarInfo();
      final prefs = await SharedPreferences.getInstance();

      await expenseRepository.deleteExpense(carNumber: car.carId, expenseId: expenseId);

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

        case ExpenseCategory.insurance:
          final updated = state.insuranceRecords.where((r) => r.id != expenseId).toList();
          emit(state.copyWith(insuranceRecords: updated));
          await prefs.setString('insurance_records', jsonEncode(updated.map((e) => e.toJson()).toList()));
          break;

        case ExpenseCategory.other:
          final updated = state.otherRecords.where((r) => r.id != expenseId).toList();
          emit(state.copyWith(otherRecords: updated));
          await prefs.setString('other_records', jsonEncode(updated.map((e) => e.toJson()).toList()));
          break;
      }

      debugPrint('The expense has been successfully removed $expenseId (${category.name})');
    } catch (e) {
      debugPrint('Error while deleting: $e');
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteAllExpenses() async {
    try {
      emit(state.copyWith(isLoading: true));

      final car = await localDataSource.getCarInfo();
      final prefs = await SharedPreferences.getInstance();

      await expenseRepository.deleteAllExpenses(carNumber: car.carId);

      await prefs.remove('service_records');
      await prefs.remove('tuning_records');
      await prefs.remove('fuel_records');
      await prefs.remove('car_wash_records');
      await prefs.remove('insurance_records');
      await prefs.remove('other_records');

      emit(
        state.copyWith(
          serviceRecords: [],
          tuningRecords: [],
          fuelRecords: [],
          carWashRecords: [],
          insuranceRecords: [],
          otherRecords: [],
          isLoading: false,
        ),
      );

      debugPrint("All expenses removed for ${car.carId}");
    } catch (e, st) {
      debugPrint("deleteAllExpenses error: $e\n$st");
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
    emit(const MaintenanceState(serviceRecords: [], tuningRecords: [], fuelRecords: [], carWashRecords: []));
  }

  /// Wipes the on-device expense cache (the [SharedPreferences] keys
  /// [_loadAllFromPrefs] reads, not just the in-memory state [clearAllRecords]
  /// resets) - called on sign-out so the next account signed into on this
  /// device starts from Firestore instead of instantly showing whichever
  /// car's records this device last cached.
  Future<void> clearCachedRecords() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in const [
      'service_records',
      'fuel_records',
      'tuning_records',
      'car_wash_records',
      'insurance_records',
      'other_records',
    ]) {
      await prefs.remove(key);
    }
    clearAllRecords();
  }

  @override
  Future<void> close() {
    try {
      _carSub.cancel();
    } catch (_) {}
    try {
      _expensesSub?.cancel();
    } catch (_) {}
    return super.close();
  }
}

extension MileageCalculations on MaintenanceCubit {
  Map<String, int> getMonthlyMileage() {
    final allRecords = [
      ...state.serviceRecords.map((r) => {'date': DateFormat('dd.MM.yyyy').parse(r.date), 'mileage': r.mileage}),
      ...state.fuelRecords.map((r) => {'date': r.date, 'mileage': r.mileage}),
      ...state.carWashRecords.map((r) => {'date': r.date, 'mileage': r.mileage}),
      ...state.tuningRecords.map((r) => {'date': r.date, 'mileage': r.mileage}),
      ...state.otherRecords.map((r) => {'date': r.date, 'mileage': r.mileage}),
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

  /// The odometer reading to prefill new entries with. Picks the highest
  /// mileage across every record type rather than sorting by date: an
  /// odometer only ever goes up, so the max is always the most recent
  /// reading - unlike a date sort, this isn't thrown off by same-day
  /// entries or by [ServiceRecord.date] being day-only (no time-of-day)
  /// while the other record types store a full [DateTime].
  int? getLastKnownMileage() {
    final allMileages = [
      ...state.serviceRecords.map((r) => r.mileage),
      ...state.fuelRecords.map((r) => r.mileage),
      ...state.carWashRecords.map((r) => r.mileage),
      ...state.tuningRecords.map((r) => r.mileage),
      ...state.otherRecords.map((r) => r.mileage),
    ];

    if (allMileages.isEmpty) return null;
    return allMileages.reduce((a, b) => a > b ? a : b);
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
    Expense Function(T record, String ownerId) mapper,
  ) async {
    final car = await localDataSource.getCarInfo();
    final ownerId = FirebaseAuth.instance.currentUser!.uid;
    for (var r in records) {
      try {
        await expenseRepository.addExpense(carNumber: car.carId, expense: mapper(r, ownerId));
      } catch (e) {
        debugPrint("Failed to save ${category.name} record: $e");
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
