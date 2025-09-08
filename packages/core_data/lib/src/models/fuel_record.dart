class FuelRecord {
  final String fuelType;
  final double volume; 
  final double cost; 
  final String date;
  final int mileage;

  FuelRecord({
    required this.fuelType,
    required this.volume,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  Map<String, dynamic> toJson() => {
        'fuelType': fuelType,
        'volume': volume,
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };

  factory FuelRecord.fromJson(Map<String, dynamic> json) => FuelRecord(
        fuelType: json['fuelType'],
        volume: json['volume'],
        cost: json['cost'],
        date: json['date'],
        mileage: json['mileage'],
      );
}
