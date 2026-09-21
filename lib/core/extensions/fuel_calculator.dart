import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:flutter/foundation.dart';


Future<double> calculateAverageFuelConsumptionAsync(List<FuelRecord> records) {
  return compute(_calculateAverageFuelConsumption, records);
}

double _calculateAverageFuelConsumption(List<FuelRecord> allRecords) {
  // Electricity is measured in kWh, not liters - it would skew l/100km.
  final records = allRecords.where((r) => r.fuelType != FuelType.Electric.name).toList();
  if (records.length < 2) return 0.0;
  final sorted = List<FuelRecord>.from(records)..sort((a, b) => a.mileage.compareTo(b.mileage));

  // "Full tank to full tank": the fuel added by every fill-up after the first
  // full one, up to and including the last full one, is what was burned over
  // that distance. The first full fill-up only marks the starting point.
  final fullTanks = sorted.where((r) => r.fullTank).toList();
  if (fullTanks.length >= 2) {
    final startMileage = fullTanks.first.mileage;
    final endMileage = fullTanks.last.mileage;
    final distance = (endMileage - startMileage).toDouble();
    if (distance > 0) {
      final liters = sorted
          .where((r) => r.mileage > startMileage && r.mileage <= endMileage)
          .fold<double>(0.0, (sum, r) => sum + r.volume);
      final avg = liters / distance * 100.0;
      if (avg.isFinite) return avg;
    }
  }

  // No pair of full-tank fill-ups yet - fall back to the rough estimate.
  final distance = (sorted.last.mileage - sorted.first.mileage).toDouble();
  if (distance <= 0) return 0.0;
  final totalLiters = sorted.fold<double>(0.0, (sum, r) => sum + (r.volume));
  final avgPer100km = totalLiters / distance * 100.0;
  if (avgPer100km.isNaN || avgPer100km.isInfinite) return 0.0;
  return avgPer100km;
}
