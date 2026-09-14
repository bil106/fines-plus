import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/user_not_signed_in_exception.dart';
import 'package:fines_plus/core/extensions/safe_prefs.dart';
import 'package:fines_plus/core/services/carplates_service.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/export/data/repository/injector.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'car_info_state.dart';
import 'dart:async';
import 'dart:io';

class CarInfoCubit extends Cubit<CarInfoState> {
  final CarInfoRepository _repo;
  final HistoryCubit historyCubit;

  CarInfoCubit(this._repo, this.historyCubit) : super(const CarInfoState()) {
    loadSavedCarInfo();
  }

  static final carReg = RegExp(r'^[A-Z]{2}\d{4}[A-Z]{2}$');
  static final techReg = RegExp(r'^[A-Z]{3}\d{6}$');

  Future<void> loadSavedCarInfo() async {
    final m = await _repo.getCarInfo();
    emit(state.copyWith(carNumber: m.carNumber, techPassport: m.techPassport, carDetails: null));

    if (m.carNumber.isNotEmpty) {
      await _saveCarToFirestore(m);
    }
  }

  Future<void> _saveCarToFirestore(CarInfoModel m) async {
    if (m.carNumber.isEmpty || !carReg.hasMatch(m.carNumber)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseFirestore.instance.collection("users").doc(user.uid).collection("cars").doc(m.carNumber);

      final token = await _getFcmTokenSafely();

      final data = <String, dynamic>{"techPassport": m.techPassport, "updatedAt": FieldValue.serverTimestamp()};

      if (token != null) data["fcmToken"] = token;

      await ref.set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
  
      debugPrint('Firestore error: ${e.code}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
    }
  }

  Future<String?> _getFcmTokenSafely() async {
    try {
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('CarInfoCubit: APNS token is not ready yet, skip FCM token');
          return null;
        }
      }

      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('CarInfoCubit: failed to get FCM token: $e');
      return null;
    }
  }




 Future<void> setCarNumber(String value) async {

    final carNumber = value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    
    emit(state.copyWith(carNumber: carNumber));

    
    if (!carReg.hasMatch(carNumber)) {
      return;
    }

  
    final user = FirebaseAuth.instance.currentUser;
    final ownerId = user?.uid ?? '';
    final m = CarInfoModel(carNumber: carNumber, techPassport: state.techPassport, ownerId: ownerId);

  
    await _saveCarToFirestore(m);

    
    try {
      final carCubit = getIt<CarCubit>();
      await carCubit.changeCar(carNumber);
    } catch (e) {
      debugPrint("CarCubit not found: $e");
    }

    await _repo.saveCarInfo(m); 
  }

  Future<void> setTechPassport(String value) async {
    final techPassport = value.trim().toUpperCase();
    final user = FirebaseAuth.instance.currentUser;
    final ownerId = user?.uid ?? '';

    final m = CarInfoModel(carNumber: state.carNumber, techPassport: techPassport, ownerId: ownerId);

    await _repo.saveCarInfo(m);
    emit(state.copyWith(techPassport: techPassport));

    await _saveCarToFirestore(m);

    try {
      await getIt<MaintenanceCubit>().syncExpensesFromFirestore();
    } catch (e) {
      debugPrint("Failed to update expenses after changing the registration certificate: $e");
    }
  }

  bool get isFormValid =>
      carReg.hasMatch(state.carNumber) && (state.techPassport.isEmpty || techReg.hasMatch(state.techPassport));

  String? validate() {
    if (!carReg.hasMatch(state.carNumber)) return 'Enter the correct car number';
    if (state.techPassport.isNotEmpty && !techReg.hasMatch(state.techPassport)) {
      return 'Enter the correct registration number';
    }
    return null;
  }

  Map<String, String> getTechPassportParts() {
    final value = state.techPassport;
    if (value.length == 9) {
      return {'series': value.substring(0, 3), 'number': value.substring(3)};
    }
    return {'series': '', 'number': ''};
  }

  Future<void> checkFinesWithCaptcha(String captchaToken) async {
    final prefs = await SharedPreferences.getInstance();
    final finesEnabled = prefs.getBoolSafe("finesCheck", defaultValue: true);

    if (!finesEnabled) {
      emit(state.copyWith(status: CarInfoErrorStatus(S.current.fine_checking_disabled)));
      return;
    }

    final error = validate();
    if (error != null) {
      emit(state.copyWith(status: CarInfoErrorStatus(error)));
      return;
    }

    emit(state.copyWith(status: CarInfoLoadingStatus()));

    final carNumber = state.carNumber;
    final parts = getTechPassportParts();

    try {
      final finesList = await _repo.getFines(
        carNumber: carNumber,
        docSeries: parts['series']!,
        docNumber: parts['number']!,
        captchaToken: captchaToken,
      );

      await historyCubit.addHistory(
        carNumber: carNumber,
        docSeries: parts['series']!,
        docNumber: parts['number']!,
        fines: finesList,
      );

      emit(state.copyWith(status: CarInfoLoadedStatus(finesList)));
    } on UserNotSignedInException catch (_) {
      emit(state.copyWith(status: CarInfoUnauthorizedStatus()));
    } catch (e) {
      emit(state.copyWith(status: CarInfoErrorStatus(e.toString())));
    }
  }

  Future<void> loadCarDetailsFromApi() async {
    if (state.carNumber.isEmpty) return;

    emit(state.copyWith(status: CarInfoLoadingStatus()));

    try {
      final carData = await CarPlatesService().fetchCarInfo(state.carNumber);
      emit(state.copyWith(status: CarInfoLoadedStatus([]), carDetails: carData));
    } catch (e) {
      emit(state.copyWith(status: CarInfoErrorStatus('Failed to load car details: $e')));
    }
  }

  Future<void> deleteCurrentCar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final carNumber = state.carNumber;
    if (carNumber.isEmpty) return;

    try {
      final analyticsCubit = getIt<AnalyticsCubit>();
      analyticsCubit.stopListeningToCar();
    } catch (_) {}

    try {
      final expensesCubit = getIt<ExpensesCubit>();
      expensesCubit.clearExpensesForCar();
    } catch (_) {}

    emit(state.copyWith(status: CarInfoLoadingStatus()));

    try {
      await _repo.deleteCar(carNumber);

      emit(const CarInfoState());
    } catch (e) {
      emit(state.copyWith(status: CarInfoErrorStatus(e.toString())));
    }
  }



}
