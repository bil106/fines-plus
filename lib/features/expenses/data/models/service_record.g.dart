// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceRecord _$ServiceRecordFromJson(Map<String, dynamic> json) =>
    ServiceRecord(
      id: json['id'] as String?,
      serviceName: json['serviceName'] as String,
      cost: (json['cost'] as num).toDouble(),
      date: json['date'] as String,
      mileage: (json['mileage'] as num).toInt(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$ServiceRecordToJson(ServiceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceName': instance.serviceName,
      'cost': instance.cost,
      'date': instance.date,
      'mileage': instance.mileage,
      'currency': instance.currency,
    };
