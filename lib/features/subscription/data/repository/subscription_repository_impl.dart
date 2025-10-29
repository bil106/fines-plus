import 'package:cloud_firestore/cloud_firestore.dart';
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
      return SubscriptionPlan(id: p.id, title: p.title, price: price, months: months);
    }).toList();
  }

  @override
  Future<void> buySubscription(String userId, SubscriptionPlan plan) async {
    final response = await iap.queryProductDetails({plan.id});
    if (response.productDetails.isEmpty) throw Exception("Product not found");


    final purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
    await iap.buyNonConsumable(purchaseParam: purchaseParam);


    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'isSubscribed': true,
    }, SetOptions(merge: true));
  }


//   Future<void> _markSubscribed(String userId, SubscriptionPlan plan) async {
//     await firestore.collection('users').doc(userId).update({
//       'isSubscribed': true,
//       'subscriptionId': plan.id,
//       'subscriptionMonths': plan.months,
//       'subscriptionDate': FieldValue.serverTimestamp(),
//     });
//   }
}

