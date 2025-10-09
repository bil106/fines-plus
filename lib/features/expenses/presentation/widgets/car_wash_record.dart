import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';


class CarWashRecord {
  final DateTime date;
  final int amount;
  final int mileage;
  final String? comment;

  CarWashRecord({required this.date, required this.amount, required this.mileage, this.comment});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'amount': amount,
    'mileage': mileage,
    'comment': comment,
  };

  factory CarWashRecord.fromJson(Map<String, dynamic> json) => CarWashRecord(
    date: DateTime.parse(json['date'] as String),
    amount: json['amount'] as int,
    mileage: json['mileage'] as int,
    comment: json['comment'] as String?,
  );


  Expense toExpense(String userId) {
    return Expense(
      date: date,
      amount: amount,
      mileage: mileage,
      comment: comment,
      category: ExpenseCategory.carWash, 
      userId: userId,
    );
  }
}
