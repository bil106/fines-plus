import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_event.dart';

abstract class ISubscriptionRepository {
  Stream<PurchaseEvent> get events;
  Future<List<SubscriptionPlan>> getAvailablePlans();

  Future<void> startPurchase(SubscriptionPlan plan);

  Future<void> restorePurchases();
  Future<UserSubscription> loadUserSubscription(String ownerId);
  Future<void> buySubscription(String ownerId, SubscriptionPlan plan);
}
