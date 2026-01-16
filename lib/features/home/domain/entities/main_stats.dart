class MainStats {
  final int lastOdometer;
  final double totalCost;
  final double averageFuelConsumption;
  final double monthMileage;

  const MainStats({
    required this.lastOdometer,
    required this.totalCost,
    required this.averageFuelConsumption,
    required this.monthMileage,
  });

  double get costPerKm {
    if (!totalCost.isFinite || monthMileage <= 0) {
      return 0.0;
    }
    return totalCost / monthMileage;
  }

  double get totalCostPercent => _safePercent(totalCost, 185000);

  double get costPerKmPercent => _safePercent(costPerKm, 20);

  double get fuelPercent => _safePercent(averageFuelConsumption, 25);

  static double _safePercent(double value, double max) {
    if (!value.isFinite || max <= 0) {
      return 0.0;
    }
    return (value / max).clamp(0.0, 1.0);
  }
}



