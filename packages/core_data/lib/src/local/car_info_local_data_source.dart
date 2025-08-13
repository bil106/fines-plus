import 'package:core_data/src/models/car_info_model.dart';
import 'shared_prefs_manager.dart';

class CarInfoLocalDataSource {
  CarInfoLocalDataSource(this.prefs);

  final SharedPrefsManager prefs;

  static const _carKey = 'car_number';
  static const _techKey = 'tech_passport';

  Future<void> saveCarInfo(CarInfoModel model) async {
    await prefs.setString(_carKey, model.carNumber.trim());
    await prefs.setString(_techKey, model.techPassport.trim());
  }

  Future<CarInfoModel> getCarInfo() async {
    final car = prefs.getString(_carKey) ?? '';
    final tech = prefs.getString(_techKey) ?? '';
    return CarInfoModel(carNumber: car, techPassport: tech);
  }


  Future<void> saveCarNumber(String v) async => prefs.setString(_carKey, v.trim());
  Future<void> saveTechPassport(String v) async => prefs.setString(_techKey, v.trim());
}
