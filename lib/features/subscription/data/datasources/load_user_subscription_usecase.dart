

import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository_impl.dart';

class LoadUserSubscriptionUseCase {
  final SubscriptionRepositoryImpl repository;

  LoadUserSubscriptionUseCase(this.repository);

  Future<UserSubscription> call(String userId) {
    return repository.loadUserSubscription(userId);
  }
}

