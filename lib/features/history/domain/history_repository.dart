import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/user_not_signed_in_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw UserNotSignedInException();

    final docRef = firestore.collection('fines_history').doc();
  final data = {
      'userId': user.uid,
      'carNumber': carNumber.trim().toUpperCase(),
      'docSeries': docSeries,
      'docNumber': docNumber,
      'fines': fines,
      'checkedAt': Timestamp.now(),
    };

    await docRef.set(data);
    if (kDebugMode) print('History added: ${docRef.id}');
  }


Stream<List<FineHistory>> getHistory(String carNumber) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw UserNotSignedInException();

    return firestore
        .collection('fines_history')
        .where('userId', isEqualTo: user.uid) 
        .where('carNumber', isEqualTo: carNumber.trim().toUpperCase())
        .orderBy('checkedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FineHistory.fromJson(d.id, d.data())).toList());
  }


  Future<void> deleteAll(String carNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User is not signed in");

    final snapshot = await firestore
        .collection('fines_history')
        .where('userId', isEqualTo: user.uid)
        .where('carNumber', isEqualTo: carNumber.trim().toUpperCase())
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    if (kDebugMode) {
      print('All history removed for $carNumber');
    }
  }

  Future<void> deleteSingle(String docId) async {
    final docRef = firestore.collection('fines_history').doc(docId);
    await docRef.delete();

    if (kDebugMode) {
      print('Record $docId removed');
    }
  }
}
