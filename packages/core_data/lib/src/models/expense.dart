

import 'package:core_data/src/models/expense_category.dart';

class Expense {
  final DateTime date;
  final int amount;
  final ExpenseCategory category;

  Expense({
    required this.date,
    required this.amount,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
        'category': category.name,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        date: DateTime.parse(json['date']),
        amount: json['amount'],
        category: ExpenseCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => ExpenseCategory.other,
        ),
      );
}
