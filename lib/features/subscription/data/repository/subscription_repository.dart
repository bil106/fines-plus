import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';

abstract class ISubscriptionRepository {
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<void> buySubscription(String userId, SubscriptionPlan plan);
}
