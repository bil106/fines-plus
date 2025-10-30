// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FuelRecord _$FuelRecordFromJson(Map<String, dynamic> json) => FuelRecord(
  id: json['id'] as String?,
  fuelType: json['fuelType'] as String,
  volume: (json['volume'] as num).toDouble(),
  cost: (json['cost'] as num).toDouble(),
  date: FuelRecord._fromJsonDate(json['date'] as String),
  mileage: (json['mileage'] as num).toInt(),
);

Map<String, dynamic> _$FuelRecordToJson(FuelRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fuelType': instance.fuelType,
      'volume': instance.volume,
      'cost': instance.cost,
      'date': FuelRecord._toJsonDate(instance.date),
      'mileage': instance.mileage,
    };
