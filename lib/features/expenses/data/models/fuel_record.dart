import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
import 'expense.dart'; 
import 'expense_category.dart'; 

part 'fuel_record.g.dart';

@JsonSerializable(explicitToJson: true)
class FuelRecord {
  final String? id;
  final String fuelType;
  final double volume;
  final double cost;


  @JsonKey(fromJson: _fromJsonDate, toJson: _toJsonDate)
  final DateTime date;

  final int mileage;

  const FuelRecord({
    this.id,
    required this.fuelType,
    required this.volume,
    required this.cost,
    required this.date,
    required this.mileage,
  });

  
  factory FuelRecord.fromJson(Map<String, dynamic> json) => _$FuelRecordFromJson(json);

  Map<String, dynamic> toJson() => _$FuelRecordToJson(this);

  
  factory FuelRecord.fromExpense(Expense expense) {
    return FuelRecord(
      id: expense.id,
      fuelType: expense.comment ?? 'fuel',
      volume: expense.fuelVolume ?? 0.0,
      cost: expense.amount.toDouble(),
      date: expense.date,
      mileage: expense.mileage ?? 0,
    );
  }

  
  Expense toExpense(String userId) {
    return Expense(
      date: date,
      amount: cost.round(),
      category: ExpenseCategory.fuel,
      mileage: mileage,
      comment: fuelType,
      userId: userId,
      fuelVolume: volume,
    );
  }

 
  static DateTime _fromJsonDate(String date) {
    try {
      return DateFormat('dd.MM.yyyy').parse(date);
    } catch (_) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
  }

  static String _toJsonDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);
}
