// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuning_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuningRecord _$TuningRecordFromJson(Map<String, dynamic> json) => TuningRecord(
  id: json['id'] as String?,
  tuningName: json['tuningName'] as String,
  cost: (json['cost'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  mileage: (json['mileage'] as num).toInt(),
);

Map<String, dynamic> _$TuningRecordToJson(TuningRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tuningName': instance.tuningName,
      'cost': instance.cost,
      'date': instance.date.toIso8601String(),
      'mileage': instance.mileage,
    };
