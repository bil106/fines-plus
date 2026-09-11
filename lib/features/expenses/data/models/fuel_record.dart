import 'package:cloud_firestore/cloud_firestore.dart';
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

  final String currency; 

  const FuelRecord({
    this.id,
    required this.fuelType,
    required this.volume,
    required this.cost,
    required this.date,
    required this.mileage,
    required this.currency, 
  });

  factory FuelRecord.fromJson(Map<String, dynamic> json) => _$FuelRecordFromJson(json);

  Map<String, dynamic> toJson() => _$FuelRecordToJson(this);

  factory FuelRecord.fromExpense(Expense expense, {required String currency}) {
    return FuelRecord(
      id: expense.id,
      fuelType: expense.comment ?? 'fuel',
      volume: expense.fuelVolume ?? 0.0,
      cost: expense.amount.toDouble(),
      date: expense.date,
      mileage: expense.mileage ?? 0,
      currency: currency, 
    );
  }

  Expense toExpense(String ownerId) {
    return Expense(
      date: date,
      amount: cost.round(),
      category: ExpenseCategory.fuel,
      mileage: mileage,
      comment: fuelType,
      ownerId: ownerId,
      fuelVolume: volume,
    );
  }

static DateTime _fromJsonDate(dynamic raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }

    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }

    if (raw is String) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        try {
          return DateFormat('dd.MM.yyyy').parse(raw);
        } catch (_) {
          return DateTime.now();
        }
      }
    }

    return DateTime.now();
  }


  static dynamic _toJsonDate(DateTime date) => date.toIso8601String();


}
