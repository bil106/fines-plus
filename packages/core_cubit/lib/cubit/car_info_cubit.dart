import 'package:core_data/core_data.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'car_info_state.dart';

class CarInfoCubit extends Cubit<CarInfoState> {
  CarInfoCubit(this._repo) : super(const CarInfoState()) {
    _load();
  }

  final CarInfoRepository _repo;

  final _carReg = RegExp(r'^[А-ЯЇІЄҐ]{2}\d{4}[А-ЯЇІЄҐ]{2}$');
  final _techReg = RegExp(r'^[А-ЯЇІЄҐ]{2} \d{6}$');

  Future<void> _load() async {
    final m = await _repo.getCarInfo();
    emit(state.copyWith(carNumber: m.carNumber, techPassport: m.techPassport));
  }

  Future<void> setCarNumber(String v) async {
    final m = CarInfoModel(carNumber: v, techPassport: state.techPassport);
    await _repo.saveCarInfo(m);
    emit(state.copyWith(carNumber: v.trim()));
  }

  Future<void> setTechPassport(String v) async {
    final m = CarInfoModel(carNumber: state.carNumber, techPassport: v);
    await _repo.saveCarInfo(m);
    emit(state.copyWith(techPassport: v.trim()));
  }

  bool get isFormValid => _carReg.hasMatch(state.carNumber) && _techReg.hasMatch(state.techPassport);

  String? validate() {
    if (!isFormValid) {
      if (!_carReg.hasMatch(state.carNumber)) return 'Введіть коректний номер авто';
      if (!_techReg.hasMatch(state.techPassport)) return 'Введіть коректний номер техпаспорта';
    }
    return null;
  }
}
