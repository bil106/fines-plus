// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_wash_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarWashRecord _$CarWashRecordFromJson(Map<String, dynamic> json) =>
    CarWashRecord(
      id: json['id'] as String?,
      amount: (json['cost'] as num).toDouble(),
      date: const DateFormatterConverter().fromJson(json['date'] as String),
      mileage: (json['mileage'] as num).toInt(),
      userId: json['userId'] as String,
      comment: json['comment'] as String?,
      currency: json['currency'] as String?,
      carNumber: json['carNumber'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$CarWashRecordToJson(CarWashRecord instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'comment': instance.comment,
      'carNumber': instance.carNumber,
      'isSynced': instance.isSynced,
      'id': instance.id,
      'cost': instance.amount,
      'date': const DateFormatterConverter().toJson(instance.date),
      'mileage': instance.mileage,
      'currency': instance.currency,
    };
