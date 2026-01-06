import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_event.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final InAppPurchase _iap;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final _controller = StreamController<PurchaseEvent>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  final Map<String, ProductDetails> _products = {};
  bool _disposed = false;

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
    if (_disposed) return;

    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Billing not available');
    }

    final response = await _iap.queryProductDetails({plan.id});
    if (response.productDetails.isEmpty) {
      throw Exception('Product not found: ${plan.id}');
    }

    final product = response.productDetails.first;
    _products[product.id] = product;

    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  @override
  Future<void> restorePurchases() async {
    if (_disposed) return;
    await _iap.restorePurchases();
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    final snapshot = await _firestore.collection('subscription_plans').get();

    return snapshot.docs.map((e) => SubscriptionPlan.fromJson(e.data())).toList();
  }

  @override
  Future<UserSubscription> loadUserSubscription(String ownerId) async {
    final doc = await _firestore.collection('users').doc(ownerId).get();
    if (!doc.exists) return UserSubscription.empty();
    return UserSubscription.fromJson(doc.data()!);
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    final user = _auth.currentUser;
    if (user == null || _disposed) return;

    for (final p in purchases) {
      try {
        if (p.status == PurchaseStatus.error) {
          _safeAdd(PurchaseEvent.error(p.error?.message));
        }

        if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
          await _handleSuccess(p, user.uid);
          _safeAdd(PurchaseEvent.success());
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s);
      }
    }
  }

  Future<void> _handleSuccess(PurchaseDetails p, String uid) async {
    final product = _products[p.productID];
    if (product == null) return;

    final months = p.productID == 'sub_quarter' ? 3 : 12;
    final endDate = DateTime.now().add(Duration(days: months * 30));

    await _firestore.collection('users').doc(uid).set({
      'isSubscribed': true,
      'subscriptionEndDate': endDate,
    }, SetOptions(merge: true));

    if (p.pendingCompletePurchase) {
      await _iap.completePurchase(p);
    }
  }

  void _safeAdd(PurchaseEvent event) {
    if (!_disposed && !_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _disposed = true;
    _purchaseSub?.cancel();
    _controller.close();
  }
  
  @override
  Future<void> buySubscription(String ownerId, SubscriptionPlan plan) {
 
    throw UnimplementedError();
  }
}

