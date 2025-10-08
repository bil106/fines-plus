import 'package:core_data/core_data.dart';

abstract class BaseRecord {
  final DateTime date;
  final double amount;
  final ExpenseCategory category;
  final String userId;
  final int? mileage;
  final String? comment;
  final String? currency;
  final String? carNumber;
  bool isSynced;

  BaseRecord({
    required this.date,
    required this.amount,
    required this.category,
    required this.userId,
    this.mileage,
    this.comment,
    this.currency,
    this.carNumber,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {};
   Expense toExpense(String userId);
}

