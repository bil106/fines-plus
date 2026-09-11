import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_event.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final InAppPurchase _iap;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
bool _purchaseInProgress = false;

  final _controller = StreamController<PurchaseEvent>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  final Map<String, ProductDetails> _products = {};
  bool _disposed = false;

  SubscriptionRepository(this._iap, this._auth, this._firestore) {
    _initPurchaseListener();
  }

  Future<void> _initPurchaseListener() async {
    try {
      final available = await _iap.isAvailable().timeout(const Duration(seconds: 5));
      if (!available || _disposed) return;
      _purchaseSub = _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onError: (e, s) {
          FirebaseCrashlytics.instance.recordError(e, s);
          _safeAdd(PurchaseEvent.error(e.toString()));
        },
      );
    } catch (_) {
      // Billing not available on this device — skip purchase stream
    }
  }

  @override
  Stream<PurchaseEvent> get events => _controller.stream;
  Future<void> _showBillingDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).purchase_not_available),
        content: Text(S.of(context).create_account),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(S.of(context).close)),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final url = Env.googlePlayUrl;
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
            child: Text(S.of(context).open_google_play),
          ),
        ],
      ),
    );
  }

@override
  Future<void> startPurchase(SubscriptionPlan plan, {BuildContext? context}) async {
    if (_disposed || _purchaseInProgress) return;

    final available = await _iap.isAvailable();
    if (!available) {
      if (context != null) {
        await _showBillingDialog(context);
        return;
      }
      throw Exception(S.current.create_account);
    }

    _purchaseInProgress = true;

    try {
      // Re-check availability right before launching to catch cases where the
      // billing client disconnected between the outer isAvailable() call and now.
      final stillAvailable = await _iap.isAvailable();
      if (!stillAvailable) {
        throw Exception('Billing service disconnected');
      }

      final response = await _iap.queryProductDetails({plan.id});
      if (response.productDetails.isEmpty) {
        FirebaseCrashlytics.instance.log('Product not found: ${plan.id}, errors: ${response.error}');
        _safeAdd(PurchaseEvent.error('store_unavailable'));
        return;
      }

      final product = response.productDetails.first;
      _products[product.id] = product;

      final success = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!success) {
        FirebaseCrashlytics.instance.log('buyNonConsumable returned false for ${plan.id}');
        _safeAdd(PurchaseEvent.error('launch_failed'));
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      rethrow;
    } finally {
      _purchaseInProgress = false;
    }
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
    if (_disposed) return;

    for (final p in purchases) {
      try {
        FirebaseCrashlytics.instance.log('Purchase update: ${p.productID}, status: ${p.status}');

        if (p.status == PurchaseStatus.pending) {
          // Pending purchase blocks new billing flows — surface it as a soft error
          // so the UI resets and the user can try again when payment clears.
          FirebaseCrashlytics.instance.log('Purchase pending: ${p.productID}');
          _safeAdd(PurchaseEvent.error('pending'));
          continue;
        }

        if (p.status == PurchaseStatus.error) {
          _safeAdd(PurchaseEvent.error(p.error?.message));
          await _completePurchaseSafely(p);
          continue;
        }

        if (p.status == PurchaseStatus.canceled) {
          // Must emit an event so PurchaseCubit resets _inProgress and the
          // buy button becomes tappable again.
          _safeAdd(PurchaseEvent.error('canceled'));
          await _completePurchaseSafely(p);
          continue;
        }

        if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
          final user = _auth.currentUser;
          if (user != null) {
            await _handleSuccess(p, user.uid);
            _safeAdd(PurchaseEvent.success());
          }
          await _completePurchaseSafely(p);
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s);
        await _completePurchaseSafely(p);
      }
    }
  }

  Future<void> _completePurchaseSafely(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(p);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'completePurchase failed');
    }
  }

  Future<void> _handleSuccess(PurchaseDetails p, String uid) async {
    final months = p.productID == 'sub_quarter' ? 3 : 12;
    final endDate = DateTime.now().add(Duration(days: months * 30));

    await _firestore.collection('users').doc(uid).set({
      'isSubscribed': true,
      'subscriptionEndDate': endDate,
    }, SetOptions(merge: true));
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
  Future<void> buySubscription(String ownerId, SubscriptionPlan plan) async {
    await startPurchase(plan);
  }
}
