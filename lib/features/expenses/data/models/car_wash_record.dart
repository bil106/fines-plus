// ignore_for_file: overridden_fields

import 'package:fines_plus/features/expenses/data/models/base_record.dart';
import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:core_utils/formatters/date_formatter.dart';


part 'car_wash_record.g.dart';

/// JsonConverter для работы с DateTime через DateFormatter
class DateFormatterConverter implements JsonConverter<DateTime, String> {
  const DateFormatterConverter();

  @override
  DateTime fromJson(String json) {
    try {
      final parts = json.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  String toJson(DateTime object) {
    return DateFormatter.formatDate(object);
  }
}

@JsonSerializable()
class CarWashRecord extends BaseRecord {
  final String? id;

  @override
  @JsonKey(name: 'cost')
  final double amount; 

  @override
  @DateFormatterConverter()
  final DateTime date;

  @override
  final int mileage;

  CarWashRecord({
    this.id,
    required this.amount,
    required this.date,
    required this.mileage,
    required super.userId,
    super.comment,
    super.currency,
    super.carNumber,
    super.isSynced,
  }) : super(
         date: date,
         amount: amount,
         category: ExpenseCategory.carWash,
         mileage: mileage,
       );

  
  factory CarWashRecord.fromJson(Map<String, dynamic> json) => _$CarWashRecordFromJson(json);

 
  @override
  Map<String, dynamic> toJson() => _$CarWashRecordToJson(this);


  factory CarWashRecord.fromExpense(Expense expense) {
    return CarWashRecord(
      id: expense.id,
      amount: expense.amount.toDouble(),
      date: expense.date,
      mileage: expense.mileage ?? 0,
      userId: expense.userId,
      comment: expense.comment,
      currency: expense.currency,
      carNumber: expense.carNumber,
      isSynced: false,
    );
  }


 @override
  Expense toExpense(String userId) {
    return Expense(
      id: id,
      date: date,
      amount: amount.round(), 
      category: ExpenseCategory.carWash,
      mileage: mileage,
      comment: comment ?? "Car Wash",
      userId: userId,
      currency: currency ?? "", 
      carNumber: carNumber,
    );
  }

}
