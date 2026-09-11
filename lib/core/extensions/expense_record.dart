import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';

part 'expense_record.g.dart';

@JsonSerializable()
class ExpenseRecord {
  final String date;
  final double amount;

  @JsonKey(fromJson: expenseCategoryFromString, toJson: expenseCategoryToString)
  final ExpenseCategory category;

  ExpenseRecord({required this.date, required this.amount, required this.category});

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) => _$ExpenseRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseRecordToJson(this);
}
