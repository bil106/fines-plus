
import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';

abstract class ISubscriptionRepository {
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<void> buySubscription(String userId, SubscriptionPlan plan);
    Future<UserSubscription> loadUserSubscription(String userId);
  Future<void> restorePurchases();
}
