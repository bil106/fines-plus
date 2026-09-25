// ignore_for_file: unnecessary_type_check

import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'service_record.g.dart';

enum ServiceType { plannedService, brakeChange, oilChange, other }

@JsonSerializable()
class ServiceRecord {
  final String? id;
  final String serviceName;
  final double cost;
  final String date;
  final int mileage;
  final String currency; 

  ServiceRecord({
    this.id,
    required this.serviceName,
    required this.cost,
    required this.date,
    required this.mileage,
    required this.currency, 
  });


  factory ServiceRecord.fromJson(Map<String, dynamic> json) => _$ServiceRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceRecordToJson(this);


  factory ServiceRecord.fromExpense(Expense expense) {
    final dateValue = expense.date;
    final formattedDate = (dateValue is DateTime) ? DateFormat('dd.MM.yyyy').format(dateValue) : dateValue.toString();

    return ServiceRecord(
      id: expense.id,
      serviceName: expense.comment ?? 'Service',
      cost: expense.amount.toDouble(),
      date: formattedDate,
      mileage: expense.mileage ?? 0,
      currency: expense.currency.isNotEmpty ? expense.currency : "UAH", 
    );
  }

 
  Expense toExpense(String ownerId) {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd.MM.yyyy').parse(date);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return Expense(
      id: id,
      date: parsedDate,
      amount: cost,
      category: ExpenseCategory.service,
      mileage: mileage,
      ownerId: ownerId,
      comment: serviceName,
      currency: currency, 
    );
  }
}
