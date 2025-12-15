import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_repository/user_not_signed_in_exception.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_local_data_source.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_remote_data_source.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
Future<void> deleteCar(String carNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw UserNotSignedInException();

    final carRef = FirebaseFirestore.instance.collection("cars").doc(carNumber);
    final expensesSnapshot = await carRef.collection("expenses").get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in expensesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(carRef);

    await batch.commit();
  }



}
