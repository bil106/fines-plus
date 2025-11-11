import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/expenses/data/models/expense.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

class ExpenseRepository {
  final FirebaseFirestore firestore;

  ExpenseRepository(this.firestore);

  CollectionReference _expensesCollection(String carNumber) {
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
    final col = _expensesCollection(carNumber);
    return col.orderBy('date', descending: true).limit(limit).snapshots().map((snap) {
      return snap.docs.map((d) => Expense.fromFirestore(d.data() as Map<String, dynamic>, id: d.id)).toList();
    });
  }

  Future<List<Expense>> getExpensesOnce({required String carNumber, int limit = 1000}) async {
    final col = _expensesCollection(carNumber);
    final snap = await col.orderBy('date', descending: true).limit(limit).get();
    return snap.docs.map((d) => Expense.fromFirestore(d.data() as Map<String, dynamic>, id: d.id)).toList();
  }

  Future<void> updateExpense({
    required String carNumber,
    required String expenseId,
    required Map<String, dynamic> updatedFields,
  }) async {
    final col = _expensesCollection(carNumber);
    updatedFields['updatedAt'] = FieldValue.serverTimestamp();
    await col.doc(expenseId).update(updatedFields);
  }

  Future<void> deleteExpense({required String carNumber, required String expenseId}) async {
    final col = _expensesCollection(carNumber);
    await col.doc(expenseId).delete();
  }

  Future<void> deleteAllExpenses({required String carNumber}) async {
    final col = _expensesCollection(carNumber);
    final query = await col.get();

    if (query.docs.isEmpty) {
      debugPrint(' There is no data to delete for this vehicle $carNumber');
      return;
    }

    final batch = firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    debugPrint(' All expenses removed for the car $carNumber');
  }

  Future<void> deleteExpensesByCategory({required String carNumber, required String category}) async {
    final col = _expensesCollection(carNumber);

    final query = await col.where('category', isEqualTo: category).get();

    if (query.docs.isEmpty) {
      debugPrint(' There is no data to delete for this category. "$category" for the car $carNumber');
      return;
    }

    final batch = firestore.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    debugPrint(' All expenses of the category "$category" removed for the machine $carNumber');
  }

  Future<Expense?> getLatestExpense({required String carNumber}) async {
    final col = _expensesCollection(carNumber);
    final snap = await col.orderBy('date', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Expense.fromFirestore(doc.data() as Map<String, dynamic>, id: doc.id);
  }
}
