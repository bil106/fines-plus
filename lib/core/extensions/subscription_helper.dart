import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionHelper {
  /// The only plan that removes ads; the quarterly plan keeps them.
  static const String yearlyProductId = 'yearly_2549';

  static Future<bool> isUserSubscribed(String uid) async {
    final data = await _activeSubscription(uid);
    return data != null;
  }

  /// Whether ads are hidden for [uid]: an active subscription whose plan is
  /// ad-free. Accounts without an `adFree` flag subscribed before ads were
  /// tied to the plan and keep their ad-free experience.
  static Future<bool> isUserAdFree(String uid) async {
    final data = await _activeSubscription(uid);
    if (data == null) return false;
    return data['adFree'] as bool? ?? true;
  }

  static Future<Map<String, dynamic>?> _activeSubscription(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final end = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
    if (end == null || !end.isAfter(DateTime.now())) return null;
    return data;
  }
}
