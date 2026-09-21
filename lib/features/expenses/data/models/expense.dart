import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'expense.g.dart';

@JsonSerializable()
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
  final String ownerId;
  final String? carNumber;
  final double? fuelVolume;

  // Insurance-specific, mirroring how fuelVolume was added for fuel: the
  // policy's insurer/number/expiry don't fit in the single generic
  // `comment` string, and are only ever set for ExpenseCategory.insurance.
  final String? insuranceCompany;
  final String? insurancePolicyNumber;
  final DateTime? insuranceValidTo;

  Expense({
    this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.ownerId,
    this.mileage,
    this.comment,
    this.currency = 'UAH',
    this.createdAt,
    this.updatedAt,
    this.carNumber,
    this.fuelVolume,
    this.insuranceCompany,
    this.insurancePolicyNumber,
    this.insuranceValidTo,
  });

  /// Firestore-specific serialization
Map<String, dynamic> toFirestore({bool isNew = false}) {
    return {
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'category': category.name,
      'mileage': mileage,
      'comment': comment,
      'currency': currency,
      'ownerId': ownerId,
      'carNumber': carNumber,
      'fuelVolume': fuelVolume,
      'insuranceCompany': insuranceCompany,
      'insurancePolicyNumber': insurancePolicyNumber,
      'insuranceValidTo': insuranceValidTo == null ? null : Timestamp.fromDate(insuranceValidTo!),
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }


  /// Firestore-specific factory
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
      ownerId: (json['ownerId'] is String) ? json['ownerId'] as String : '',
      carNumber: json['carNumber'] as String?,
      fuelVolume: (json['fuelVolume'] is num)
          ? (json['fuelVolume'] as num).toDouble()
          : double.tryParse(json['fuelVolume']?.toString() ?? '0.0'),
      insuranceCompany: json['insuranceCompany'] as String?,
      insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
      insuranceValidTo: json['insuranceValidTo'] is Timestamp ? (json['insuranceValidTo'] as Timestamp).toDate() : null,
    );
  }

  /// JSON serialization for other purposes
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
