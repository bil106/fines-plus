// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_expense_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyExpenseStats _$MonthlyExpenseStatsFromJson(Map<String, dynamic> json) =>
    MonthlyExpenseStats(
      monthLabel: json['monthLabel'] as String,
      total: (json['total'] as num).toDouble(),
      categoryTotals: (json['categoryTotals'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          $enumDecode(_$ExpenseCategoryEnumMap, k),
          (e as num).toDouble(),
        ),
      ),
      electricTotal: (json['electricTotal'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$MonthlyExpenseStatsToJson(
  MonthlyExpenseStats instance,
) => <String, dynamic>{
  'monthLabel': instance.monthLabel,
  'total': instance.total,
  'categoryTotals': instance.categoryTotals.map(
    (k, e) => MapEntry(_$ExpenseCategoryEnumMap[k]!, e),
  ),
  'electricTotal': instance.electricTotal,
};

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.fuel: 'fuel',
  ExpenseCategory.service: 'service',
  ExpenseCategory.tuning: 'tuning',
  ExpenseCategory.carWash: 'carWash',
  ExpenseCategory.insurance: 'insurance',
  ExpenseCategory.other: 'other',
};
