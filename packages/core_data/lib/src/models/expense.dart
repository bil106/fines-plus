import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';

class Expense {
  final String? id;
  final DateTime date;
  final int amount;
  final ExpenseCategory category;
  final int? mileage;
  final String? comment;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userId;
  final String? carNumber;
  final double? fuelVolume;

  Expense({
    this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.userId,
    this.mileage,
    this.comment,
    this.currency = 'UAH',
    this.createdAt,
    this.updatedAt,
    this.carNumber,
    this.fuelVolume,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'category': category.name,
      'mileage': mileage,
      'comment': comment,
      'currency': currency,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'carNumber': carNumber,
      'fuelVolume': fuelVolume,
    };
  }

  factory Expense.fromFirestore(Map<String, dynamic> json, {String? id}) {
    dynamic dateField = json['date'];
    DateTime date;
    if (dateField is Timestamp) {
      date = dateField.toDate();
    } else if (dateField is String) {
      date = DateTime.tryParse(dateField) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    DateTime? created;
    final createdField = json['createdAt'];
    if (createdField is Timestamp) created = createdField.toDate();

    DateTime? updated;
    final updatedField = json['updatedAt'];
    if (updatedField is Timestamp) updated = updatedField.toDate();

    final categoryStr = (json['category'] as String?) ?? 'other';
    ExpenseCategory category;
    try {
      category = ExpenseCategory.values.firstWhere((e) => e.name == categoryStr);
    } catch (_) {
      category = ExpenseCategory.other;
    }

    return Expense(
      id: id,
      date: date,
      amount: (json['amount'] ?? 0) is int ? (json['amount'] ?? 0) as int : (json['amount'] ?? 0).round(),
      category: category,
      mileage: json['mileage'] as int?,
      comment: json['comment'] as String?,
      currency: (json['currency'] as String?) ?? 'UAH',
      createdAt: created,
      updatedAt: updated,
      userId: (json['userId'] is String) ? json['userId'] as String : '',
      carNumber: json['carNumber'] as String?,
      fuelVolume: (json['fuelVolume'] is num)
          ? (json['fuelVolume'] as num).toDouble()
          : double.tryParse(json['fuelVolume']?.toString() ?? '0.0'),
    );
  }

}
