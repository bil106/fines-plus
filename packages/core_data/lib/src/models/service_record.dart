enum ServiceType {
  plannedService,
  brakeChange,
  oilChange,
  other,
}

class ServiceRecord {
  final ServiceType type;
  final String date;
  final int mileage;
  final double cost;
  final String notes;

  ServiceRecord({
    required this.type,
    required this.date,
    required this.mileage,
    required this.cost,
    required this.notes,
  });
}
