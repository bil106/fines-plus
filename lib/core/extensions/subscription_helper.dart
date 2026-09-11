import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionHelper {
  static Future<bool> isUserSubscribed(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    final end = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
    if (end == null) return false;
    return end.isAfter(DateTime.now());
  }
}
