// ignore_for_file: unnecessary_type_check

import 'package:intl/intl.dart';
import 'package:core_data/core_data.dart';

class FuelRecord {
  final String? id;
  final String fuelType;
  final double volume;
  final double cost;
  final String date; 
  final int mileage;

  FuelRecord({
    this.id,
    required this.fuelType,
    required this.volume,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  factory FuelRecord.fromJson(Map<String, dynamic> json) => FuelRecord(
        id: json['id'] as String?,
        fuelType: json['fuelType'] ?? '',
        volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
        cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        mileage: json['mileage'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
        'fuelType': fuelType,
        'volume': volume,
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };


factory FuelRecord.fromExpense(Expense expense) {
    final formattedDate =
        (expense.date is DateTime) ? DateFormat('dd.MM.yyyy').format(expense.date) : (expense.date.toString());

    return FuelRecord(
      id: expense.id,
      fuelType: expense.comment ?? 'fuel',
      volume: expense.fuelVolume ?? 0.0, 
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
      category: ExpenseCategory.fuel,
      mileage: mileage,
      comment: fuelType,
      userId: userId,
      fuelVolume: volume
    );
  }
}
