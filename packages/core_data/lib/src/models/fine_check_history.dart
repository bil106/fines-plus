import 'package:cloud_firestore/cloud_firestore.dart';


class FineHistory {
  final String id;
  final String userId;
  final String carNumber;
  final String docSeries;
  final String docNumber;
  final DateTime checkedAt;
  final List<Map<String, dynamic>> fines;
  final Set<String> paidFines;

  FineHistory({
    required this.id,
    required this.userId,
    required this.carNumber,
    required this.docSeries,
    required this.docNumber,
    required this.checkedAt,
    required this.fines,
    this.paidFines = const {},
  });

  FineHistory copyWith({Set<String>? paidFines}) {
    return FineHistory(
      id: id,
      userId: userId,
      carNumber: carNumber,
      docSeries: docSeries,
      docNumber: docNumber,
      checkedAt: checkedAt,
      fines: fines,
      paidFines: paidFines ?? this.paidFines,
    );
  }

  factory FineHistory.fromJson(String id, Map<String, dynamic> json) {
    final checked = json['checkedAt'];
    final checkedAt = checked is Timestamp ? checked.toDate() : DateTime.now();

    final finesList = (json['fines'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];

    final paidList = (json['paidFines'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? <String>{};

    return FineHistory(
      id: id,
      userId: (json['userId'] as String?) ?? '',
      carNumber: (json['carNumber'] as String?) ?? '',
      docSeries: (json['docSeries'] as String?) ?? '',
      docNumber: (json['docNumber'] as String?) ?? '',
      checkedAt: checkedAt,
      fines: finesList,
      paidFines: paidList,
    );
  }
}
