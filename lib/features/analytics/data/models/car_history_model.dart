import 'package:json_annotation/json_annotation.dart';

part 'car_history_model.g.dart';

@JsonSerializable()
class CarHistory {
  final String type;
  final String date;
  final int mileage;
  final double cost;

  CarHistory({required this.type, required this.date, required this.mileage, required this.cost});

  factory CarHistory.fromJson(Map<String, dynamic> json) => _$CarHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$CarHistoryToJson(this);
}
