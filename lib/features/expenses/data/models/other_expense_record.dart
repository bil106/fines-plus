import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';

part 'other_expense_record.g.dart';

/// A one-off expense that doesn't fit fuel/service/tuning/car wash - the
/// "Інше" tile in the dashboard's "Ще" sheet.
@JsonSerializable()
class OtherExpenseRecord {
  final String? id;
  final DateTime date;
  final double cost;
  final int mileage;
  final String currency;
  final String? comment;

  const OtherExpenseRecord({
    this.id,
    required this.date,
    required this.cost,
    required this.mileage,
    required this.currency,
    this.comment,
  });

  factory OtherExpenseRecord.fromJson(Map<String, dynamic> json) => _$OtherExpenseRecordFromJson(json);

  Map<String, dynamic> toJson() => _$OtherExpenseRecordToJson(this);

  factory OtherExpenseRecord.fromExpense(Expense expense) {
    return OtherExpenseRecord(
      id: expense.id,
      date: expense.date,
      cost: expense.amount.toDouble(),
      mileage: expense.mileage ?? 0,
      currency: expense.currency,
      comment: expense.comment,
    );
  }

  Expense toExpense(String ownerId) {
    return Expense(
      id: id,
      date: date,
      amount: cost,
      category: ExpenseCategory.other,
      mileage: mileage,
      ownerId: ownerId,
      comment: comment,
      currency: currency,
    );
  }
}
