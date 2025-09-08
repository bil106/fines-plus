enum ServiceType {
  plannedService,
  brakeChange,
  oilChange,
  other,
}

class ServiceRecord {
  final String serviceName; 
  final double cost; 
  final String date;
  final int mileage;

  ServiceRecord({
    required this.serviceName,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) => ServiceRecord(
        serviceName: json['serviceName'],
        cost: json['cost'],
        date: json['date'],
        mileage: json['mileage'],
      );

  Map<String, dynamic> toJson() => {
        'serviceName': serviceName,
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };
}

