import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/subscription/data/models/subscription_status.dart';
import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final InAppPurchase iap;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  SubscriptionRepositoryImpl(this.iap, this.auth, this.firestore) {
    _purchaseSub = iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _purchaseSub?.cancel(),
      onError: (e) => debugPrint('Purchase stream error: $e'),
    );
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    final user = auth.currentUser;
    if (user == null) return;

    for (final p in purchases) {
      try {
        if (p.status == PurchaseStatus.pending) {
          debugPrint('Purchase pending: ${p.productID}');
        }  else if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {


  final productResponse = await iap.queryProductDetails({p.productID});
  if (productResponse.productDetails.isEmpty) continue;
  final product = productResponse.productDetails.first;

  final price = double.tryParse(product.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
  final currency = product.currencyCode;

 
  final now = DateTime.now();
  final months = p.productID == 'sub_quarter' ? 3 : 12;
  final endDate = DateTime(now.year, now.month + months, now.day);
  final trialEndDate = now.add(const Duration(days: 7));

  await firestore.collection('users').doc(user.uid).set({
    'isSubscribed': true,
    'subscriptionEndDate': endDate,
    'trialEndsAt': trialEndDate,
  }, SetOptions(merge: true));

  await firestore.collection('purchases').doc(p.purchaseID).set({
    'uid': user.uid,
    'amount': price,
    'currency': currency,
    'months': months,
    'source': 'play',
    'subscriptionEndDate': endDate,
    'trialEndsAt': trialEndDate,
    'createdAt': FieldValue.serverTimestamp(),
  });

  if (p.pendingCompletePurchase) {
    await iap.completePurchase(p);
  } else {
    await iap.completePurchase(p);
  }


        } else if (p.status == PurchaseStatus.error) {
          debugPrint('Purchase error for ${p.productID}: ${p.error}');
        }
      } catch (e, st) {
        debugPrint('Error processing purchase ${p.productID}: $e\n$st');
      }
    }
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    if (!await iap.isAvailable()) return [];
    const ids = {'sub_quarter', 'yearly_2549'};
    final response = await iap.queryProductDetails(ids);
    return response.productDetails.map((p) {
      final price = double.tryParse(p.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
      final months = p.id == 'sub_quarter' ? 3 : 12;
      return SubscriptionPlan(id: p.id, title: p.title, price: price, months: months, features: []);
    }).toList();
  }

  @override
  Future<void> buySubscription(String userId, SubscriptionPlan plan) async {
    final response = await iap.queryProductDetails({plan.id});
    if (response.productDetails.isEmpty) throw Exception("Product not found");
    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    await iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<UserSubscription> loadUserSubscription(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) return UserSubscription(status: SubscriptionStatus.none);

    final data = doc.data()!;
    final isSubscribed = data['isSubscribed'] == true;
    final endDate = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
    final trialEnd = (data['trialEndsAt'] as Timestamp?)?.toDate();

    SubscriptionStatus status;
    if (!isSubscribed || endDate == null || endDate.isBefore(DateTime.now())) {
      status = SubscriptionStatus.none;
    } else if (trialEnd != null && trialEnd.isAfter(DateTime.now())) {
      status = SubscriptionStatus.trial;
    } else {
      status = SubscriptionStatus.subscribed;
    }

    return UserSubscription(status: status, subscriptionEndDate: endDate, trialEndsAt: trialEnd);
  }

  @override
  Future<void> restorePurchases() async {
    await iap.restorePurchases();
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
  }
}
