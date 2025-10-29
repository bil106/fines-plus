// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseRecord _$ExpenseRecordFromJson(Map<String, dynamic> json) =>
    ExpenseRecord(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: expenseCategoryFromString(json['category'] as String),
    );

Map<String, dynamic> _$ExpenseRecordToJson(ExpenseRecord instance) =>
    <String, dynamic>{
      'date': instance.date,
      'amount': instance.amount,
      'category': expenseCategoryToString(instance.category),
    };
