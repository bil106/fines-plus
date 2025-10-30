// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarHistory _$CarHistoryFromJson(Map<String, dynamic> json) => CarHistory(
  type: json['type'] as String,
  date: json['date'] as String,
  mileage: (json['mileage'] as num).toInt(),
  cost: (json['cost'] as num).toDouble(),
);

Map<String, dynamic> _$CarHistoryToJson(CarHistory instance) =>
    <String, dynamic>{
      'type': instance.type,
      'date': instance.date,
      'mileage': instance.mileage,
      'cost': instance.cost,
    };
