import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/user_not_signed_in_exception.dart';
import 'package:fines_plus/core/extensions/safe_prefs.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_local_data_source.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarCubit extends Cubit<CarState> {
  final CarInfoLocalDataSource local;
  final CarInfoRepository repo;
  final AppConfig config;
  late HistoryCubit _historyCubit;


  CarCubit({required this.local, required this.repo, required this.config}) : super(const CarState()) {
    _init();
  }


  void setHistoryCubit(HistoryCubit historyCubit) {
    _historyCubit = historyCubit;
  }

  Future<void> _init() async {
    final info = await local.getCarInfo();
    emit(state.copyWith(carNumber: info.carNumber, techPassport: info.techPassport, carId: info.carId));
    await ensureCarId();
  }

  /// Guarantees the signed-in user has a stable car id, generating one (via
  /// a Firestore auto-id) the first time — this is what a "skip" registration
  /// relies on: no plate yet, but a real car identity to store data against.
  /// Safe to call repeatedly (a no-op once an id exists).
  ///
  /// Also covers the pre-update-install migration path: [local.ensureCarId]
  /// may adopt a pre-existing car doc and backfill carNumber/techPassport
  /// locally, so this re-reads and emits all three together afterward.
  Future<String> ensureCarId() async {
    final carId = await local.ensureCarId();
    if (carId.isEmpty) return carId;

    if (carId != state.carId) {
      final info = await local.getCarInfo();
      emit(state.copyWith(carId: info.carId, carNumber: info.carNumber, techPassport: info.techPassport));
    }
    return carId;
  }

  /// Makes [car] (a garage entry) the active one and reflects it in state,
  /// so every screen keyed off [CarState.carId]/[CarState.carNumber] follows.
  Future<void> switchActiveCar(CarInfoModel car) async {
    await local.switchActiveCar(car);
    emit(state.copyWith(carId: car.carId, carNumber: car.carNumber, techPassport: car.techPassport));
  }

  /// Used after deleting the last remaining car in the garage — clears the
  /// active car entirely and creates a fresh, plate-less default one.
  Future<void> resetToNewDefaultCar() async {
    final carId = await local.resetToNewDefaultCar();
    emit(state.copyWith(carId: carId, carNumber: '', techPassport: ''));
  }

  static final _carReg = RegExp(r'^[A-Z]{2}\d{4}[A-Z]{2}$');

  /// On a full, valid plate, checks whether this account already has a car
  /// with that exact number (e.g. re-typed on a new device after local
  /// prefs were lost) and reattaches to it instead of relabeling whatever
  /// blank car is currently active, which would otherwise orphan its
  /// existing expenses/maintenance/schedule data under the old carId.
  Future<void> changeCar(String newCar) async {
    final trimmed = newCar.trim();
    if (trimmed == state.carNumber) return;

    if (_carReg.hasMatch(trimmed)) {
      final existing = await local.findCarByNumber(trimmed, excludeCarId: state.carId);
      if (existing != null) {
        await switchActiveCar(existing);
        return;
      }
    }

    await local.saveCarNumber(trimmed);
    emit(state.copyWith(carNumber: trimmed));
  }

  Future<void> setTechPassport(String tech) async {
    final t = tech.trim();
    await local.saveTechPassport(t);
    emit(state.copyWith(techPassport: t));
  }

  /// Make/photo aren't part of [CarState] (nothing else in the app reads
  /// them off the active car) — they're written straight to the active
  /// car's Firestore doc, same place the garage list reads them back from.
  Future<void> setMake(String make) => local.saveMake(make);

  Future<void> setPhotoUrl(String url) => local.savePhotoUrl(url);

  Map<String, String> getTechPassportParts() {
    final value = state.techPassport;
    if (value.length == 9) {
      return {'series': value.substring(0, 3), 'number': value.substring(3)};
    }
    return {'series': '', 'number': ''};
  }

  Future<void> checkFines(String captchaToken) async {
    // Ukraine-only feature (talks to a UA government portal via a captcha +
    // the owner's own documents) - brands/markets that don't have it must
    // not be able to trigger it even if some UI path slips through.
    if (!config.finesCheckEnabled) {
      debugPrint("Fine checking disabled for this brand");
      return;
    }

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

  /// Why a fines check can't start right now (brand/setting off, car data
  /// invalid), or null when it can. Reads the active car straight from this
  /// cubit, so it follows garage switches.
  Future<String?> finesCheckBlocker() async {
    if (!config.finesCheckEnabled) return S.current.fine_checking_disabled;
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.getBoolSafe("finesCheck", defaultValue: true)) {
      return S.current.fine_checking_disabled;
    }
    if (!_isFormValid()) return S.current.enter_correct_number_auto;
    return null;
  }

  /// Stores fines read off the official MVS page for the active car.
  Future<void> saveCheckedFines(List<Map<String, dynamic>> fines) {
    final parts = getTechPassportParts();
    return _historyCubit.addHistory(
      carNumber: state.carNumber,
      docSeries: parts['series']!,
      docNumber: parts['number']!,
      fines: fines,
    );
  }

  bool _isFormValid() {
    final carReg = RegExp(r'^[A-Z]{2}\d{4}[A-Z]{2}$');
    final techReg = RegExp(r'^[A-Z]{3}\d{6}$');
    return carReg.hasMatch(state.carNumber) && (state.techPassport.isEmpty || techReg.hasMatch(state.techPassport));
  }
}

