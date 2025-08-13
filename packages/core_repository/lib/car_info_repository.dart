// ignore_for_file: unnecessary_library_name

library core_repository;

export 'car_info_repository.dart';
import 'package:core_data/core_data.dart';

class CarInfoRepository {
  CarInfoRepository(this.local);

  final CarInfoLocalDataSource local;

  Future<void> saveCarInfo(CarInfoModel model) => local.saveCarInfo(model);
  Future<CarInfoModel> getCarInfo() => local.getCarInfo();

  Future<void> saveCarNumber(String v) => local.saveCarNumber(v);
  Future<void> saveTechPassport(String v) => local.saveTechPassport(v);
  Future<String> getCarNumber() async => (await local.getCarInfo()).carNumber;
  Future<String> getTechPassport() async => (await local.getCarInfo()).techPassport;
}
