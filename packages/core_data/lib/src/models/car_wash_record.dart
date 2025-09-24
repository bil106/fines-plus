class CarWashRecord {
  final double cost;
  final String date;
  final int mileage;

  CarWashRecord({
    required this.cost,
    required this.date,
    required this.mileage,
  });

  Map<String, dynamic> toJson() => {
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };

  factory CarWashRecord.fromJson(Map<String, dynamic> json) => CarWashRecord(
        cost: json['cost'],
        date: json['date'],
        mileage: json['mileage'],
      );
}
