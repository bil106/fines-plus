// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsuranceRecord _$InsuranceRecordFromJson(Map<String, dynamic> json) =>
    InsuranceRecord(
      id: json['id'] as String?,
      company: json['company'] as String,
      policyNumber: json['policyNumber'] as String,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      cost: (json['cost'] as num).toDouble(),
      currency: json['currency'] as String,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InsuranceRecordToJson(InsuranceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company': instance.company,
      'policyNumber': instance.policyNumber,
      'validFrom': instance.validFrom.toIso8601String(),
      'validTo': instance.validTo.toIso8601String(),
      'cost': instance.cost,
      'currency': instance.currency,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
