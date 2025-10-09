import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';


abstract class HistoryRemoteDataSource {
  Future<List<FineHistory>> getHistory(String carNumber);
  Future<void> addHistory(String carNumber, FineHistory history);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore firestore;

  HistoryRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> addHistory(String carNumber, FineHistory history) async {
    final normalizedCarNumber = carNumber.trim().toUpperCase();

    final collectionRef = firestore.collection('fines_history');

    final docRef = history.id.isNotEmpty ? collectionRef.doc(history.id) : collectionRef.doc();

    await docRef.set({
      'carNumber': normalizedCarNumber,
      'docSeries': history.docSeries,
      'docNumber': history.docNumber,
      'fines': history.fines,
      'checkedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<FineHistory>> getHistory(String carNumber) async {
    final normalizedCarNumber = carNumber.trim().toUpperCase();

    final snapshot = await firestore
        .collection('fines_history')
        .where('carNumber', isEqualTo: normalizedCarNumber)
        .orderBy('checkedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => FineHistory.fromJson(doc.id, doc.data())).toList();
  }
}
