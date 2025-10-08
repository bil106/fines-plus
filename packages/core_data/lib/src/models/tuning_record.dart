// ignore_for_file: unnecessary_type_check

import 'package:intl/intl.dart';
import 'package:core_data/core_data.dart';

class TuningRecord {
  final String? id;
  final String tuningName;
  final double cost;
  final String date; 
  final int mileage;

  TuningRecord({
     this.id,
    required this.tuningName,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  factory TuningRecord.fromJson(Map<String, dynamic> json) => TuningRecord(
       id: json['id'] as String?,
        tuningName: json['tuningName'] ?? '',
        cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        mileage: json['mileage'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
     if (id != null) 'id': id,
        'tuningName': tuningName,
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };

  
  factory TuningRecord.fromExpense(Expense expense) {
    final formattedDate =
        (expense.date is DateTime) ? DateFormat('dd.MM.yyyy').format(expense.date) : (expense.date.toString());

    return TuningRecord(
       id: expense.id,
      tuningName: expense.comment ?? 'Tuning',
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
      category: ExpenseCategory.tuning,
      mileage: mileage,
      comment: tuningName,
      userId: userId,
    );
  }
}
