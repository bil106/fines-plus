// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_expense_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtherExpenseRecord _$OtherExpenseRecordFromJson(Map<String, dynamic> json) =>
    OtherExpenseRecord(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      cost: (json['cost'] as num).toDouble(),
      mileage: (json['mileage'] as num).toInt(),
      currency: json['currency'] as String,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$OtherExpenseRecordToJson(OtherExpenseRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'cost': instance.cost,
      'mileage': instance.mileage,
      'currency': instance.currency,
      'comment': instance.comment,
    };
