import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_event.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final InAppPurchase _iap;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final StreamController<PurchaseEvent> _controller = StreamController<PurchaseEvent>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _disposed = false;

  final Map<String, ProductDetails> _products = {};

  SubscriptionRepository(this._iap, this._auth, this._firestore) {
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s);
        _safeAdd(PurchaseEvent.error(e.toString()));
      },
    );
  }

  @override
  Stream<PurchaseEvent> get events => _controller.stream;

  @override
  Future<void> startPurchase(SubscriptionPlan plan) async {
    FirebaseCrashlytics.instance.log('startPurchase: ${plan.id}');

    if (_disposed) return;

    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Billing not available');
    }

    if (!_products.containsKey(plan.id)) {
      final response = await _iap.queryProductDetails({plan.id});
      if (response.productDetails.isEmpty) {
        throw Exception('Product not found: ${plan.id}');
      }
      _products[plan.id] = response.productDetails.first;
    }

    final product = _products[plan.id]!;

    final purchaseParam = PurchaseParam(productDetails: product);

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() async {
    if (_disposed) return;
    FirebaseCrashlytics.instance.log('restorePurchases');
    await _iap.restorePurchases();
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    final snapshot = await _firestore.collection('subscription_plans').get();

    return snapshot.docs.map((doc) => SubscriptionPlan.fromJson(doc.data())).toList();
  }

  @override
  Future<UserSubscription> loadUserSubscription(String ownerId) async {
    final doc = await _firestore.collection('users').doc(ownerId).get();

    if (!doc.exists) {
      return UserSubscription.empty();
    }

    return UserSubscription.fromJson(doc.data()!);
  }

  @override
  Future<void> buySubscription(String ownerId, SubscriptionPlan plan) async {
    if (_auth.currentUser?.uid != ownerId) {
      throw Exception('User mismatch');
    }
    await startPurchase(plan);
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    if (_disposed) return;

    final user = _auth.currentUser;
    if (user == null) return;

    for (final p in purchases) {
      FirebaseCrashlytics.instance.log('purchase update: ${p.productID}, status=${p.status}');

      try {
        switch (p.status) {
          case PurchaseStatus.error:
            _safeAdd(PurchaseEvent.error(p.error?.message ?? 'Purchase error'));
            break;

          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            await _handleSuccess(p, user.uid);
            _safeAdd(PurchaseEvent.success());
            break;

          case PurchaseStatus.pending:
            FirebaseCrashlytics.instance.log('purchase pending');
            break;

          default:
            break;
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s);
        _safeAdd(PurchaseEvent.error(e.toString()));
      }
    }
  }

 Future<void> _handleSuccess(PurchaseDetails p, String uid) async {
    if (_disposed) return;

    final product = _products[p.productID];
    if (product == null) return;

    final price = double.tryParse(product.price.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    final months = p.productID == 'sub_quarter' ? 3 : 12;
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day).add(Duration(days: months * 30));

    if (_disposed) return;
    try {
      await _firestore.collection('users').doc(uid).set({
        'isSubscribed': true,
        'subscriptionEndDate': endDate,
      }, SetOptions(merge: true));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }

    if (_disposed) return;
    try {
      await _firestore.collection('purchases').doc(p.purchaseID).set({
        'uid': uid,
        'productId': p.productID,
        'amount': price,
        'currency': product.currencyCode,
        'months': months,
        'source': 'play',
        'createdAt': FieldValue.serverTimestamp(),
        'subscriptionEndDate': endDate,
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }

    if (_disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('subscription_end_timestamp', endDate.millisecondsSinceEpoch);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }

    if (_disposed) return;
    if (p.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(p);
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }


  void _safeAdd(PurchaseEvent event) {
    if (_disposed || _controller.isClosed) return;
    _controller.add(event);
  }

  void dispose() {
    FirebaseCrashlytics.instance.log('SubscriptionRepository disposed');
    _disposed = true;
    _purchaseSub?.cancel();
    _controller.close();
  }
}
