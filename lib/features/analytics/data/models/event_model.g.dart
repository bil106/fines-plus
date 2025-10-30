// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  date: EventModel._dateFromJson(json['date'] as String),
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  mileage: json['mileage'] as String,
  iconCodePoint: (json['iconCodePoint'] as num).toInt(),
  iconColorValue: (json['iconColorValue'] as num).toInt(),
  category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'date': EventModel._dateToJson(instance.date),
      'title': instance.title,
      'amount': instance.amount,
      'mileage': instance.mileage,
      'iconCodePoint': instance.iconCodePoint,
      'iconColorValue': instance.iconColorValue,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.fuel: 'fuel',
  ExpenseCategory.service: 'service',
  ExpenseCategory.tuning: 'tuning',
  ExpenseCategory.carWash: 'carWash',
  ExpenseCategory.other: 'other',
};
