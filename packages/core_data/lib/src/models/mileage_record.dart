class MileageRecord {
  final DateTime month;
  final int startOdometer;
  final int endOdometer;

  MileageRecord({
    required this.month,
    required this.startOdometer,
    required this.endOdometer,
  });

  int get mileage => endOdometer - startOdometer;

  Map<String, dynamic> toJson() => {
        'month': month.toIso8601String(),
        'startOdometer': startOdometer,
        'endOdometer': endOdometer,
      };

  factory MileageRecord.fromJson(Map<String, dynamic> json) {
    return MileageRecord(
      month: DateTime.parse(json['month']),
      startOdometer: json['startOdometer'],
      endOdometer: json['endOdometer'],
    );
  }
}
