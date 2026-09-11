import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';

class LoadUserSubscriptionUseCase {
  final ISubscriptionRepository repository;

  LoadUserSubscriptionUseCase(this.repository);

  Future<UserSubscription> call(String ownerId) {
    return repository.loadUserSubscription(ownerId);
  }
}
