// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsData _$AnalyticsDataFromJson(Map<String, dynamic> json) =>
    AnalyticsData(
      fuelLiters: (json['fuelLiters'] as num).toDouble(),
      fuelCost: (json['fuelCost'] as num).toDouble(),
      mileage: (json['mileage'] as num).toInt(),
    );

Map<String, dynamic> _$AnalyticsDataToJson(AnalyticsData instance) =>
    <String, dynamic>{
      'fuelLiters': instance.fuelLiters,
      'fuelCost': instance.fuelCost,
      'mileage': instance.mileage,
    };
