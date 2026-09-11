import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';


class CarWashRecord {
  final DateTime date;
  final int amount;
  final int mileage;
  final String? comment;
final String currency;
  CarWashRecord({required this.date, required this.amount, required this.mileage, this.comment, this.currency = "UAH"});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'amount': amount,
    'mileage': mileage,
    'currency': currency,
    'comment': comment,
  };

  factory CarWashRecord.fromJson(Map<String, dynamic> json) => CarWashRecord(
    date: DateTime.parse(json['date'] as String),
    amount: json['amount'] as int,
    mileage: json['mileage'] as int,
    currency: json['currency'] as String? ?? 'UAH',
    comment: json['comment'] as String?,
  );


  Expense toExpense(String ownerId) {
    return Expense(
      date: date,
      amount: amount,
      mileage: mileage,
      comment: comment,
      category: ExpenseCategory.carWash, 
      ownerId: ownerId,
      currency: currency, 
    );
  }
}
