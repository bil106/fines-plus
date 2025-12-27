import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_event.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final InAppPurchase iap;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  final _controller = StreamController<PurchaseEvent>.broadcast();

  @override
  Stream<PurchaseEvent> get events => _controller.stream;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  SubscriptionRepository(this.iap, this.auth, this.firestore) {
    _purchaseSub = iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (e) => _controller.add(PurchaseEvent.error(e.toString())),
    );
  }

  @override
  Future<void> startPurchase(SubscriptionPlan plan) async {
    if (!await iap.isAvailable()) {
      throw Exception('Billing not available');
    }

    final response = await iap.queryProductDetails({plan.id});
    if (response.productDetails.isEmpty) {
      throw Exception('Product not found');
    }

    await iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: response.productDetails.first));
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    final snapshot = await firestore.collection('subscription_plans').get();
    return snapshot.docs.map((doc) => SubscriptionPlan.fromJson(doc.data())).toList();
  }

  @override
  Future<UserSubscription> loadUserSubscription(String ownerId) async {
    final doc = await firestore.collection('users').doc(ownerId).get();
    if (!doc.exists) {
      return UserSubscription.empty();
    }
    return UserSubscription.fromJson(doc.data()!);
  }

  @override
  Future<void> buySubscription(String ownerId, SubscriptionPlan plan) async {
    if (auth.currentUser?.uid != ownerId) {
      throw Exception("User mismatch");
    }
    await startPurchase(plan);
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    final user = auth.currentUser;
    if (user == null) return;

    for (final p in purchases) {
      try {
        switch (p.status) {
          case PurchaseStatus.error:
            _controller.add(PurchaseEvent.error(p.error?.message ?? 'Purchase error'));
            break;

          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            await _handleSuccess(p, user.uid);
            _controller.add(PurchaseEvent.success());
            break;

          default:
            break;
        }
      } catch (e) {
        _controller.add(PurchaseEvent.error(e.toString()));
      }
    }
  }

  Future<void> _handleSuccess(PurchaseDetails p, String uid) async {
    final response = await iap.queryProductDetails({p.productID});
    if (response.productDetails.isEmpty) return;
    final product = response.productDetails.first;
    final price = double.tryParse(product.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
    final months = p.productID == 'sub_quarter' ? 3 : 12;
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month + months, now.day);
    await firestore.collection('users').doc(uid).set({
      'isSubscribed': true,
      'subscriptionEndDate': endDate,
    }, SetOptions(merge: true));
    await firestore.collection('purchases').doc(p.purchaseID).set({
      'uid': uid,
      'amount': price,
      'currency': product.currencyCode,
      'months': months,
      'source': 'play',
      'createdAt': FieldValue.serverTimestamp(),
      'subscriptionEndDate': endDate,
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('subscription_end_timestamp', endDate.millisecondsSinceEpoch);
    if (p.pendingCompletePurchase) {
      await iap.completePurchase(p);
    }
  }

  @override
  Future<void> restorePurchases() async {
    await iap.restorePurchases();
  }

  void dispose() {
    _purchaseSub?.cancel();
    _controller.close();
  }
}
