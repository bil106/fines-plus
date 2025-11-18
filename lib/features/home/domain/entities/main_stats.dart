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

  double get costPerKm => monthMileage > 0 ? totalCost / monthMileage : 0.0;

  double get totalCostPercent => (totalCost / 20000).clamp(0.0, 1.0);
  double get costPerKmPercent => (costPerKm / 17).clamp(0.0, 1.0);
  double get fuelPercent => (averageFuelConsumption / 20).clamp(0.0, 1.0);
}


