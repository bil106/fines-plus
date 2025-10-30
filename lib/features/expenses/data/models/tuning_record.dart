import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tuning_record.g.dart';

@JsonSerializable()
class TuningRecord {
  final String? id;
  final String tuningName;
  final double cost;
  final DateTime date; 
  final int mileage;

  TuningRecord({this.id, required this.tuningName, required this.cost, required this.date, required this.mileage});

  /// JSON
  factory TuningRecord.fromJson(Map<String, dynamic> json) => _$TuningRecordFromJson(json);

  Map<String, dynamic> toJson() => _$TuningRecordToJson(this);

  factory TuningRecord.fromExpense(Expense expense) {
    return TuningRecord(
      id: expense.id,
      tuningName: expense.comment ?? 'Tuning',
      cost: expense.amount.toDouble(),
      date: expense.date,
      mileage: expense.mileage ?? 0,
    );
  }

  Expense toExpense(String userId) => Expense(
    date: date,
    amount: cost.round(),
    category: ExpenseCategory.tuning,
    mileage: mileage,
    comment: tuningName,
    userId: userId,
  );
}
