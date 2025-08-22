import 'package:core_data/core_data.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'car_info_state.dart';

class CarInfoCubit extends Cubit<CarInfoState> {
  CarInfoCubit(this._repo) : super(const CarInfoState()) {
    _load();
  }

  final CarInfoRepository _repo;

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

    
    if (!isClosed) {
      emit(state.copyWith(techPassport: value));
    }
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
      final series = value.substring(0, 3);
      final number = value.substring(3);
      return {'series': series, 'number': number};
    }
    return {'series': '', 'number': ''};
  }
}
