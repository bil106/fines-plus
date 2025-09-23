enum TuningType {
  plannedService,
  other,
}

class TuningRecord {
  final String tuningName;
  final double cost;
  final String date;
  final int mileage;

  TuningRecord({
    required this.tuningName,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  factory TuningRecord.fromJson(Map<String, dynamic> json) => TuningRecord(
        tuningName: json['tuningName'],
        cost: json['cost'],
        date: json['date'],
        mileage: json['mileage'],
      );

  Map<String, dynamic> toJson() => {
        'tuningName': tuningName,
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };
}
