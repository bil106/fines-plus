import 'dart:convert';

import 'package:core_cubit/cubit/history_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'car_info_state.dart';
import 'package:fines_plus/env/env.dart';
import 'package:http/http.dart' as http;


class CarInfoCubit extends Cubit<CarInfoState> {
  final CarInfoRepository _repo;
  final HistoryCubit historyCubit;

  CarInfoCubit(this._repo, this.historyCubit) : super(const CarInfoState()) {
    _load();
  }

  final _carReg = RegExp(r'^[А-ЯЇІЄҐ]{2}\d{4}[А-ЯЇІЄҐ]{2}$');
  final _techReg = RegExp(r'^[А-ЯІЇЄҐ]{3}\d{6}$');

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

  bool get isFormValid => _carReg.hasMatch(state.carNumber) && _techReg.hasMatch(state.techPassport);

  String? validate() {
    if (!isFormValid) {
      if (!_carReg.hasMatch(state.carNumber)) return 'Введіть коректний номер авто';
      if (!_techReg.hasMatch(state.techPassport)) return 'Введіть коректний номер техпаспорта';
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

  Future<void> checkFines() async {
    final error = validate();
    if (error != null) {
      emit(state.copyWith(status: CarInfoErrorStatus(error)));
      return;
    }

    emit(state.copyWith(status: CarInfoLoadingStatus()));

    final carNumber = state.carNumber;
    final parts = getTechPassportParts();
    final series = parts['series']!;
    final number = parts['number']!;

    try {
      final captchaToken = Env.recaptchaSiteKey;
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/fines"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "carNumber": carNumber,
          "docSeries": series,
          "docNumber": number,
          "captchaToken": captchaToken,
          "cookies": "cf_clearance=XXX; _gv_sessid=YYY",
        }),
      );

      if (response.statusCode != 200) {
        emit(state.copyWith(status: CarInfoErrorStatus("Server error: ${response.statusCode}")));
        return;
      }

      final data = jsonDecode(response.body);
      final finesRaw = data['fines'];

      List<Map<String, dynamic>> finesList = [];
      if (finesRaw is List) {
        finesList = finesRaw.cast<Map<String, dynamic>>();
      } else if (finesRaw is Map<String, dynamic>) {
        finesList = [Map<String, dynamic>.from(finesRaw)];
      }

      
      await historyCubit.addHistory(
        carNumber: carNumber,
        docSeries: series,
        docNumber: number,
        fines: finesList,
      );

      emit(state.copyWith(status: CarInfoLoadedStatus(finesList)));
    } catch (e) {
      emit(state.copyWith(status: CarInfoErrorStatus(e.toString())));
    }
  }
}
