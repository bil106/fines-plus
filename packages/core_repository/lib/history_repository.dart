import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter/foundation.dart';

class HistoryRepository {
  final FirebaseFirestore firestore;

  HistoryRepository(this.firestore);

  Future<void> addToHistory({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required List<Map<String, dynamic>> fines,
  }) async {
    final docRef = firestore.collection('fines_history').doc();

    final data = {
      'carNumber': carNumber.trim().toUpperCase(),
      'docSeries': docSeries,
      'docNumber': docNumber,
      'fines': fines,
      'checkedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);
    if (kDebugMode) {
      print('✅ History added: ${docRef.id}');
    }
  }

  Stream<List<FineHistory>> getHistory(String carNumber) {
    return firestore
        .collection('fines_history')
        .where('carNumber', isEqualTo: carNumber.trim().toUpperCase())
        .orderBy('checkedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FineHistory.fromJson(doc.id, doc.data())).toList());
  }

  Future<void> deleteAll(String carNumber) async {
    final snapshot =
        await firestore.collection('fines_history').where('carNumber', isEqualTo: carNumber.trim().toUpperCase()).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    if (kDebugMode) {
      print('✅ All history removed for $carNumber');
    }
  }

  Future<void> deleteSingle(String docId) async {
    final docRef = firestore.collection('fines_history').doc(docId);
    await docRef.delete();
    if (kDebugMode) {
      print('✅ Record $docId removed');
    }
  }
}
