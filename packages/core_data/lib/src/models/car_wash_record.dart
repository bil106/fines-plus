// ignore_for_file: unnecessary_type_check

import 'package:intl/intl.dart';
import 'package:core_data/core_data.dart';

class CarWashRecord {
  final String? id;
  final double cost;
  final String date; 
  final int mileage;

  CarWashRecord({
    this.id,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  factory CarWashRecord.fromJson(Map<String, dynamic> json) => CarWashRecord(
       id: json['id'] as String?,
        cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        mileage: json['mileage'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };


  factory CarWashRecord.fromExpense(Expense expense) {
    final formattedDate =
        (expense.date is DateTime) ? DateFormat('dd.MM.yyyy').format(expense.date) : (expense.date.toString());

    return CarWashRecord(
      id: expense.id,
      cost: expense.amount.toDouble(),
      date: formattedDate,
      mileage: expense.mileage ?? 0,
    );
  }

  Expense toExpense(String userId) {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd.MM.yyyy').parse(date);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return Expense(
      
      date: parsedDate,
      amount: cost.round(),     
      category: ExpenseCategory.carWash,
      mileage: mileage,
      comment: "CarWash",
      userId: userId,
    );
  }
}
