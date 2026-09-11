import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';

import '../entities/subscription.dart';


class GetAvailablePlansUseCase {
  final ISubscriptionRepository repository;
  GetAvailablePlansUseCase(this.repository);

  Future<List<SubscriptionPlan>> call() {
    return repository.getAvailablePlans();
  }
}
