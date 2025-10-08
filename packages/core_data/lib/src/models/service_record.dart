// ignore_for_file: unnecessary_type_check

import 'package:core_data/core_data.dart';
import 'package:intl/intl.dart';

enum ServiceType {
  plannedService,
  brakeChange,
  oilChange,
  other,
}

class ServiceRecord {
  final String? id;
  final String serviceName;
  final double cost;
  final String date; 
  final int mileage;

  ServiceRecord({
    this.id,
    required this.serviceName,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) => ServiceRecord(
        id: json['id'] as String?,
        serviceName: json['serviceName'] ?? '',
        cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        mileage: json['mileage'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
     if (id != null) 'id': id,
        'serviceName': serviceName,
        'cost': cost,
        'date': date,
        'mileage': mileage,
      };


  factory ServiceRecord.fromExpense(Expense expense) {
    final dateValue = expense.date;
    final formattedDate =
        (dateValue is DateTime) ? DateFormat('dd.MM.yyyy').format(dateValue) : (dateValue.toString());

    return ServiceRecord(
      id: expense.id,
      serviceName: expense.comment ?? 'Service',
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
      id: id,
      date: parsedDate,
      amount: cost.round(),
      category: ExpenseCategory.service,
      mileage: mileage,
      userId: userId,
      comment: serviceName,
    );
  }
}
