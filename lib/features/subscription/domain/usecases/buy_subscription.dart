import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';

import '../entities/subscription.dart';


class BuySubscriptionUseCase {
  final ISubscriptionRepository repository;
  BuySubscriptionUseCase(this.repository);

  Future<void> call(String userId, SubscriptionPlan plan) {
    return repository.buySubscription(userId, plan);
  }
}
