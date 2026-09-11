import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';

abstract class BaseRecord {
  final DateTime date;
  final double amount;
  final ExpenseCategory category;
  final String ownerId;
  final int? mileage;
  final String? comment;
  final String? currency;
  final String? carNumber;
  bool isSynced;

  BaseRecord({
    required this.date,
    required this.amount,
    required this.category,
    required this.ownerId,
    this.mileage,
    this.comment,
    this.currency,
    this.carNumber,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson();

  Expense toExpense(String ownerId);
}
