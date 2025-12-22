import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

class ExpenseRepository {
  final FirebaseFirestore firestore;

  ExpenseRepository(this.firestore);
  void _assertCarNumber(String carNumber) {
    if (carNumber.isEmpty) {
      throw StateError('ExpenseRepository: carNumber is empty');
    }
  }

  CollectionReference _expensesCollection(String carNumber) {
    _assertCarNumber(carNumber);
    return firestore.collection('cars').doc(carNumber).collection('expenses');
  }

  Future<DocumentReference> addExpense({required String carNumber, required Expense expense}) async {
    final col = _expensesCollection(carNumber);
    final docRef = await col.add(expense.toFirestore());

    debugPrint('Expense saved to Firestore:');
    debugPrint('Car: $carNumber');
    debugPrint('Expense ID: ${docRef.id}');
    debugPrint('Data: ${expense.toFirestore()}');

    return docRef;
  }

  Stream<List<Expense>> watchExpenses({required String carNumber, int limit = 1000}) {
    if (carNumber.isEmpty) {
      return const Stream.empty();
    }

    final col = _expensesCollection(carNumber);
    return col
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => Expense.fromFirestore(d.data() as Map<String, dynamic>, id: d.id)).toList(),
        );
  }

Future<List<Expense>> getExpensesOnce({required String carNumber, int limit = 1000}) async {
    if (carNumber.isEmpty) return [];

    try {
      final col = _expensesCollection(carNumber);
      final snap = await col.orderBy('date', descending: true).limit(limit).get();
      return snap.docs.map((d) => Expense.fromFirestore(d.data() as Map<String, dynamic>, id: d.id)).toList();
    } catch (e) {
      debugPrint('Firestore Error: $e'); 
      return []; 
    }
  }

  Future<void> updateExpense({
    required String carNumber,
    required String expenseId,
    required Map<String, dynamic> updatedFields,
  }) async {
    if (carNumber.isEmpty) return;

    final col = _expensesCollection(carNumber);
    updatedFields['updatedAt'] = FieldValue.serverTimestamp();
    await col.doc(expenseId).update(updatedFields);
  }

  Future<void> deleteExpense({required String carNumber, required String expenseId}) async {
    if (carNumber.isEmpty) return;

    final col = _expensesCollection(carNumber);
    await col.doc(expenseId).delete();
  }

  Future<void> deleteAllExpenses({required String carNumber}) async {
    if (carNumber.isEmpty) return;

    final col = _expensesCollection(carNumber);
    final query = await col.get();

    if (query.docs.isEmpty) return;

    final batch = firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> deleteExpensesByCategory({required String carNumber, required String category}) async {
    if (carNumber.isEmpty) return;

    final col = _expensesCollection(carNumber);
    final query = await col.where('category', isEqualTo: category).get();

    if (query.docs.isEmpty) return;

    final batch = firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<Expense?> getLatestExpense({required String carNumber}) async {
    if (carNumber.isEmpty) return null;

    final col = _expensesCollection(carNumber);
    final snap = await col.orderBy('date', descending: true).limit(1).get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    return Expense.fromFirestore(doc.data() as Map<String, dynamic>, id: doc.id);
  }
}
