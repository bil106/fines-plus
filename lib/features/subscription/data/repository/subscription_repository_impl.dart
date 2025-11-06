import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fines_plus/features/subscription/data/models/subscription_status.dart';
import 'package:fines_plus/features/subscription/data/models/trial_info.dart';
import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final InAppPurchase iap;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore; 

  SubscriptionRepositoryImpl(this.iap, this.auth, this.firestore);

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    final isAvailable = await iap.isAvailable();
    if (!isAvailable) return [];

    const ids = {'sub_3_months', 'sub_6_months', 'sub_12_months'};
    final response = await iap.queryProductDetails(ids);

    return response.productDetails.map((p) {
      final price = double.tryParse(p.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
      final months = p.id == 'sub_3_months'
          ? 3
          : p.id == 'sub_6_months'
          ? 6
          : 12;
      return SubscriptionPlan(id: p.id, title: p.title, price: price, months: months, features: []);
    }).toList();
  }

@override
  Future<void> buySubscription(String userId, SubscriptionPlan plan) async {
    final response = await iap.queryProductDetails({plan.id});
    if (response.productDetails.isEmpty) throw Exception("Product not found");

    final purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
    await iap.buyNonConsumable(purchaseParam: purchaseParam);

    await firestore.collection('users').doc(userId).set({
      "subscriptionStatus": SubscriptionStatus.subscribed.name,
      "subscriptionId": plan.id,
      "subscriptionMonths": plan.months,
      "subscriptionStartDate": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }


@override
  Future<UserSubscription> loadUserSubscription(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      return UserSubscription(status: SubscriptionStatus.none);
    }

    final data = doc.data()!;
    return UserSubscription.fromJson(data);
  }
@override
  Future<void> saveTrialStart(String userId, TrialInfo trial) async {
    await firestore.collection('users').doc(userId).set({
      "subscriptionStatus": SubscriptionStatus.trialActive.name,
      "trialInfo": trial.toJson(),
    }, SetOptions(merge: true));
  }

}

