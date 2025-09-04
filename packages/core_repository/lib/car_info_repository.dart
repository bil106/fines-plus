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

  // API request
  Future<List<Map<String, dynamic>>> getFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required String captchaToken,
  }) {
    return remote.checkFines(
      carNumber: carNumber,
      docSeries: docSeries,
      docNumber: docNumber,
      captchaToken: captchaToken,
    );
  }
}
