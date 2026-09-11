import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:flutter/foundation.dart';


Future<double> calculateAverageFuelConsumptionAsync(List<FuelRecord> records) {
  return compute(_calculateAverageFuelConsumption, records);
}

double _calculateAverageFuelConsumption(List<FuelRecord> records) {
  if (records.length < 2) return 0.0;
  final sorted = List<FuelRecord>.from(records)..sort((a, b) => a.mileage.compareTo(b.mileage));
  final firstMileage = sorted.first.mileage;
  final lastMileage = sorted.last.mileage;
  final distance = (lastMileage - firstMileage).toDouble();
  if (distance <= 0) return 0.0;
  final totalLiters = sorted.fold<double>(0.0, (sum, r) => sum + (r.volume));
  final avgPer100km = totalLiters / distance * 100.0;
  if (avgPer100km.isNaN || avgPer100km.isInfinite) return 0.0;
  return avgPer100km;
}
