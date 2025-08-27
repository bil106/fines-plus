import 'package:cloud_firestore/cloud_firestore.dart';


class FineHistory {
  final String id;
  final String carNumber;
  final String docSeries;
  final String docNumber;
  final DateTime checkedAt;
  final List<Map<String, dynamic>> fines;

  FineHistory({
    required this.id,
    required this.carNumber,
    required this.docSeries,
    required this.docNumber,
    required this.checkedAt,
    required this.fines,
  });

  factory FineHistory.fromJson(String id, Map<String, dynamic> json) {
    final checked = json['checkedAt'];
    DateTime checkedAt;
    if (checked is Timestamp) {
      checkedAt = checked.toDate();
    } else {
      checkedAt = DateTime.now();
    }

    final finesList = (json['fines'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];

    return FineHistory(
      id: id,
      carNumber: (json['carNumber'] as String?) ?? '',
      docSeries: (json['docSeries'] as String?) ?? '',
      docNumber: (json['docNumber'] as String?) ?? '',
      checkedAt: checkedAt,
      fines: finesList,
    );
  }
}
