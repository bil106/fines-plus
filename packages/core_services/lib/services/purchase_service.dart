import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _keySubscriptionEnd = "subscription_end_timestamp";

  Future<void> recordPurchase({
    required String purchaseId,
    required String uid,
    required num amount,
    required int months,
    DateTime? trialEndsAt,
    String currency = 'USD',
    String source = 'play',
  }) async {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month + months, now.day);

    await _firestore.collection('purchases').doc(purchaseId).set({
      'uid': uid,
      'amount': amount,
      'months': months,
      'currency': currency,
      'source': source,
      'trialEndsAt': trialEndsAt,
      'createdAt': FieldValue.serverTimestamp(),
      'subscriptionEndDate': endDate,
    });

    await _firestore.collection('users').doc(uid).set({
      'isSubscribed': true,
      'subscriptionEndDate': endDate,
    }, SetOptions(merge: true));

 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySubscriptionEnd, endDate.millisecondsSinceEpoch);

  
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final partnerId = userDoc.data()?['partnerId'] as String?;
    if (partnerId != null && partnerId.isNotEmpty) {
      final bonus = amount * 0.2;
      await _firestore.collection('partners').doc(partnerId).set({
        'balance': FieldValue.increment(bonus),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _firestore.collection('partnerStats').doc(partnerId).set({
        'revenue': FieldValue.increment(amount),
        'bonus': FieldValue.increment(bonus),
        'paidUsers': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
  }

  Future<bool> hasActiveSubscription(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final localTs = prefs.getInt(_keySubscriptionEnd);

    if (localTs != null) {
      final endDate = DateTime.fromMillisecondsSinceEpoch(localTs);
      if (endDate.isAfter(DateTime.now())) {
        return true; 
      }
    }

    
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return false;
      final data = userDoc.data();
      if (data == null) return false;
      final isSubscribed = data['isSubscribed'] == true;
      final endDate = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
      if (!isSubscribed || endDate == null) return false;
      return endDate.isAfter(DateTime.now());
    } catch (_) {
      return false; 
    }
  }
}

