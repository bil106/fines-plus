import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/history/history_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/user_not_signed_in_exception.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'car_info_state.dart';
import 'dart:async';

class CarInfoCubit extends Cubit<CarInfoState> {
  final CarInfoRepository _repo;
  final HistoryCubit historyCubit;

  CarInfoCubit(this._repo, this.historyCubit) : super(const CarInfoState()) {
    _load();
  }

  static final carReg = RegExp(r'^[А-ЯЇІЄҐ]{2}\d{4}[А-ЯЇІЄҐ]{2}$');
  static final techReg = RegExp(r'^[А-ЯІЇЄҐ]{3}\d{6}$');

  Future<void> loadSavedCarInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final carNumber = prefs.getString('carNumber') ?? '';
    final techPassport = prefs.getString('techPassport') ?? '';

    emit(state.copyWith(carNumber: carNumber, techPassport: techPassport));

    if (carNumber.isNotEmpty) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection("cars").doc(carNumber).set({
          "fcmToken": token,
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> _load() async {
    final m = await _repo.getCarInfo();
    emit(state.copyWith(carNumber: m.carNumber, techPassport: m.techPassport));
  }

  Future<void> setCarNumber(String v) async {
    final value = v.trim().replaceAll(RegExp(r'[^А-ЯЇІЄҐ0-9]'), '');
    final m = CarInfoModel(carNumber: value, techPassport: state.techPassport);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carNumber', value);

    await _repo.saveCarInfo(m);
    emit(state.copyWith(carNumber: value));
  }

  Future<void> setTechPassport(String v) async {
    if (isClosed) return;
    final value = v.trim().toUpperCase();
    final m = CarInfoModel(carNumber: state.carNumber, techPassport: value);

    String series = '';
    String number = '';
    if (value.length == 9) {
      series = value.substring(0, 3);
      number = value.substring(3);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('techPassport', value);
    await prefs.setString('docSeries', series);
    await prefs.setString('docNumber', number);

    await _repo.saveCarInfo(m);
    emit(state.copyWith(techPassport: value));
  }

  bool get isFormValid => carReg.hasMatch(state.carNumber) && techReg.hasMatch(state.techPassport);

  String? validate() {
    if (!isFormValid) {
      if (!carReg.hasMatch(state.carNumber)) return 'Enter the correct car number';
      if (!techReg.hasMatch(state.techPassport)) return 'Enter the correct registration number';
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
    final finesEnabled = prefs.getBool("finesCheck") ?? true;

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
}
