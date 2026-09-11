import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/analytics/data/models/analytics_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

abstract class IAnalyticsRepository {
  Future<FuelData> getFuelData(String carNumber);

  Future<int> getMileage(String carNumber);

  Future<List<PieChartSectionData>> getChartData(String carNumber);
}

class FuelData {
  final double liters;
  final double amount;

  FuelData({required this.liters, required this.amount});
}

class AnalyticsRepository implements IAnalyticsRepository {
  final FirebaseFirestore firestore;

  AnalyticsRepository({required this.firestore});

 
  Future<DocumentSnapshot<Map<String, dynamic>>?> _getCarDoc(String carNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || carNumber.isEmpty) return null;

    try {
      return await firestore.collection('users').doc(user.uid).collection('cars').doc(carNumber).get();
    } catch (e) {
      debugPrint('Firestore Error fetching car doc: $e');
      return null;
    }
  }

  @override
  Future<FuelData> getFuelData(String carNumber) async {
    final doc = await _getCarDoc(carNumber);
    if (doc == null || !doc.exists) return FuelData(liters: 0, amount: 0);

    final data = doc.data()!;
    return FuelData(liters: (data['fuelLiters'] ?? 0).toDouble(), amount: (data['fuelAmount'] ?? 0).toDouble());
  }

  @override
  Future<int> getMileage(String carNumber) async {
    final doc = await _getCarDoc(carNumber);
    if (doc == null || !doc.exists) return 0;

    return (doc.data()!['mileage'] ?? 0) as int;
  }

  @override
  Future<List<PieChartSectionData>> getChartData(String carNumber) async {
    final doc = await _getCarDoc(carNumber);

   
    if (doc == null || !doc.exists) return [];

    final data = doc.data()!;
    final double greenPercent = (data['greenPercent'] ?? 0).toDouble();
    final double bluePercent = (data['bluePercent'] ?? 0).toDouble();

    
    if ((greenPercent + bluePercent) <= 0) return [];

    return [
      PieChartSectionData(value: greenPercent, color: AppColors.green, title: "${greenPercent.toInt()}%", radius: 80),
      PieChartSectionData(
        value: bluePercent,
        color: AppColors.energyBlue,
        title: "${bluePercent.toInt()}%",
        radius: 80,
      ),
    ];
  }

Future<AnalyticsData> getAnalytics(DateTime date, String carNumber) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return AnalyticsData.empty();
      }

      final isValidCar = RegExp(r'^[А-ЯЇІЄҐ]{2}\d{4}[А-ЯЇІЄҐ]{2}$').hasMatch(carNumber);
      if (!isValidCar) {
        return AnalyticsData.empty();
      }

      final doc = await firestore
          .collection('analytics')
          .doc(carNumber)
          .collection('months')
          .doc('${date.year}-${date.month}')
          .get();

      if (!doc.exists) {
        return AnalyticsData.empty();
      }

      final data = doc.data()!;
      return AnalyticsData(
        fuelLiters: (data['fuelLiters'] ?? 0).toDouble(),
        fuelCost: (data['fuelCost'] ?? 0).toDouble(),
        mileage: (data['mileage'] ?? 0).toInt(),
      );
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
    
        return AnalyticsData.empty();
      }
      rethrow;
    }
  }


}
