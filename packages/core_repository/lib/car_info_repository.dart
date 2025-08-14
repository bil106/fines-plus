// ignore_for_file: unnecessary_library_name

library core_repository;

export 'car_info_repository.dart';
import 'package:core_data/core_data.dart';

class CarInfoRepository {
  CarInfoRepository(this.local, this.remote);

  final CarInfoLocalDataSource local;
  final CarInfoRemoteDataSource remote;

  // Local saving
  Future<void> saveCarInfo(CarInfoModel model) => local.saveCarInfo(model);
  Future<CarInfoModel> getCarInfo() => local.getCarInfo();
  Future<void> saveCarNumber(String v) => local.saveCarNumber(v);
  Future<void> saveTechPassport(String v) => local.saveTechPassport(v);

  // API requests
  Future<Map<String, dynamic>> getFines(String carNumber, String techPassport) {
    return remote.checkFines(
      carNumber: carNumber,
      techPassport: techPassport,
    );
  }

  Future<Map<String, dynamic>> getInsurance(String carNumber) {
    return remote.checkInsurance(carNumber: carNumber);
  }
}

