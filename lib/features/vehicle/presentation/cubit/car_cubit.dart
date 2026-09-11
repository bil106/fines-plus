import 'package:core_repository/user_not_signed_in_exception.dart';
import 'package:fines_plus/core/extensions/safe_prefs.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_local_data_source.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarCubit extends Cubit<CarState> {
  final CarInfoLocalDataSource local;
  final CarInfoRepository repo;
  late HistoryCubit _historyCubit;


  CarCubit({required this.local, required this.repo}) : super(const CarState()) {
    _init();
  }


  void setHistoryCubit(HistoryCubit historyCubit) {
    _historyCubit = historyCubit;
  }

  Future<void> _init() async {
    final info = await local.getCarInfo();
    emit(state.copyWith(carNumber: info.carNumber, techPassport: info.techPassport));
  }

  Future<void> changeCar(String newCar) async {
    final trimmed = newCar.trim();
    if (trimmed == state.carNumber) return;
    await local.saveCarNumber(trimmed);
    emit(state.copyWith(carNumber: trimmed));
  }

  Future<void> setTechPassport(String tech) async {
    final t = tech.trim();
    await local.saveTechPassport(t);
    emit(state.copyWith(techPassport: t));
  }

  Map<String, String> getTechPassportParts() {
    final value = state.techPassport;
    if (value.length == 9) {
      return {'series': value.substring(0, 3), 'number': value.substring(3)};
    }
    return {'series': '', 'number': ''};
  }

  Future<void> checkFines(String captchaToken) async {
    final prefs = await SharedPreferences.getInstance();
    final finesEnabled = prefs.getBoolSafe("finesCheck", defaultValue: true);

    if (!finesEnabled) {
      debugPrint("Fine checking disabled");
      return;
    }

    if (!_isFormValid()) {
      debugPrint("Invalid car number or tech passport");
      return;
    }

    final carNumber = state.carNumber;
    final parts = getTechPassportParts();

    try {
      final finesList = await repo.getFines(
        carNumber: carNumber,
        docSeries: parts['series']!,
        docNumber: parts['number']!,
        captchaToken: captchaToken,
      );

  
      _historyCubit.addHistory(
        carNumber: carNumber,
        docSeries: parts['series']!,
        docNumber: parts['number']!,
        fines: finesList,
      );

      debugPrint("Fines loaded: ${finesList.length}");
    } on UserNotSignedInException catch (_) {
      debugPrint("User not signed in");
    } catch (e) {
      debugPrint("Error checking fines: $e");
    }
  }

  bool _isFormValid() {
    final carReg = RegExp(r'^[А-ЯЇІЄҐ]{2}\d{4}[А-ЯЇІЄҐ]{2}$');
    final techReg = RegExp(r'^[А-ЯІЇЄҐ]{3}\d{6}$');
    return carReg.hasMatch(state.carNumber) && techReg.hasMatch(state.techPassport);
  }
}

