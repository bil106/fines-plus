import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recordPurchase({
    required String purchaseId,
    required String uid,
    required num amount,
    String currency = 'USD',
    String source = 'play',
  }) async {
    await _firestore.collection('purchases').doc(purchaseId).set({
      'uid': uid,
      'amount': amount,
      'currency': currency,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    });

   // we credit the partner bonus immediately to the client
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final partnerId = userDoc.data()?['partnerId'] as String?;
    if (partnerId != null && partnerId.isNotEmpty) {
      final bonus = amount * 0.2; // 20% bonus by default
      await _firestore.collection('partners').doc(partnerId).set({
        'balance': FieldValue.increment(bonus),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('partnerStats').doc(partnerId).set({
        'revenue': FieldValue.increment(amount),
        'bonus': FieldValue.increment(bonus),
        'paidUsers': FieldValue.increment(1),
      }, SetOptions(merge: true));

      debugPrint("Partner $partnerId received bonus $bonus for purchase $purchaseId");
    }
  }
}

