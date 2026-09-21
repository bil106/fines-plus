// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String?,
  date: DateTime.parse(json['date'] as String),
  amount: (json['amount'] as num).toInt(),
  category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
  ownerId: json['ownerId'] as String,
  mileage: (json['mileage'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  currency: json['currency'] as String? ?? 'UAH',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  carNumber: json['carNumber'] as String?,
  fuelVolume: (json['fuelVolume'] as num?)?.toDouble(),
  fullTank: json['fullTank'] as bool? ?? false,
  insuranceCompany: json['insuranceCompany'] as String?,
  insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
  insuranceValidTo: json['insuranceValidTo'] == null
      ? null
      : DateTime.parse(json['insuranceValidTo'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'amount': instance.amount,
  'category': _$ExpenseCategoryEnumMap[instance.category]!,
  'mileage': instance.mileage,
  'comment': instance.comment,
  'currency': instance.currency,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'ownerId': instance.ownerId,
  'carNumber': instance.carNumber,
  'fuelVolume': instance.fuelVolume,
  'fullTank': instance.fullTank,
  'insuranceCompany': instance.insuranceCompany,
  'insurancePolicyNumber': instance.insurancePolicyNumber,
  'insuranceValidTo': instance.insuranceValidTo?.toIso8601String(),
};

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.fuel: 'fuel',
  ExpenseCategory.service: 'service',
  ExpenseCategory.tuning: 'tuning',
  ExpenseCategory.carWash: 'carWash',
  ExpenseCategory.insurance: 'insurance',
  ExpenseCategory.other: 'other',
};
