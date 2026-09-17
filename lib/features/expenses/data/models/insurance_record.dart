import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:json_annotation/json_annotation.dart';

part 'insurance_record.g.dart';

/// A purchased insurance policy - distinct from the existing recurring
/// *reminder* (InsuranceDetailSheet/InsuranceType under schedule/) which
/// only tracks a renewal interval, not a company/policy/cost.
@JsonSerializable()
class InsuranceRecord {
  final String? id;
  final String company;
  final String policyNumber;
  final DateTime validFrom;
  final DateTime validTo;
  final double cost;
  final String currency;

  /// When this record was last written to Firestore (server timestamp) -
  /// the reliable signal for "which record is the current policy" when two
  /// records share the same validFrom (e.g. only validTo was edited on a
  /// renewal), since validFrom/validTo are user-chosen dates, not save
  /// order.
  final DateTime? updatedAt;

  const InsuranceRecord({
    this.id,
    required this.company,
    required this.policyNumber,
    required this.validFrom,
    required this.validTo,
    required this.cost,
    required this.currency,
    this.updatedAt,
  });

  /// Generic per-record stats/mileage helpers (see MaintenanceCubit's
  /// MileageCalculations extension) read `.date` off every record type.
  DateTime get date => validFrom;

  factory InsuranceRecord.fromJson(Map<String, dynamic> json) => _$InsuranceRecordFromJson(json);

  Map<String, dynamic> toJson() => _$InsuranceRecordToJson(this);

  factory InsuranceRecord.fromExpense(Expense expense) {
    return InsuranceRecord(
      id: expense.id,
      company: expense.insuranceCompany ?? '',
      policyNumber: expense.insurancePolicyNumber ?? '',
      validFrom: expense.date,
      validTo: expense.insuranceValidTo ?? expense.date,
      cost: expense.amount.toDouble(),
      currency: expense.currency,
      updatedAt: expense.updatedAt,
    );
  }

  Expense toExpense(String ownerId) {
    return Expense(
      id: id,
      date: validFrom,
      amount: cost.round(),
      category: ExpenseCategory.insurance,
      ownerId: ownerId,
      comment: company,
      currency: currency,
      insuranceCompany: company,
      insurancePolicyNumber: policyNumber,
      insuranceValidTo: validTo,
    );
  }
}
