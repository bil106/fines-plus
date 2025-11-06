import 'package:fines_plus/features/subscription/data/models/trial_info.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository_impl.dart';



class SaveTrialInfoUseCase {
  final SubscriptionRepositoryImpl repository;

  SaveTrialInfoUseCase(this.repository);

  Future<void> call(String userId, TrialInfo info) {
    return repository.saveTrialStart(userId, info);
  }
}
