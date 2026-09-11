import 'package:json_annotation/json_annotation.dart';

part 'analytics_model.g.dart';

@JsonSerializable()
class AnalyticsData {
  final double fuelLiters;
  final double fuelCost;
  final int mileage;

  AnalyticsData({required this.fuelLiters, required this.fuelCost, required this.mileage});

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => _$AnalyticsDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsDataToJson(this);
  
  factory AnalyticsData.empty() =>  AnalyticsData(fuelLiters: 0, fuelCost: 0, mileage: 0);
}
