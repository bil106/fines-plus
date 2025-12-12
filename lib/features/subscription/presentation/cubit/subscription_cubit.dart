import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final ISubscriptionRepository repository;
  SubscriptionPlan? selectedPlan;

  SubscriptionCubit(this.repository) : super(SubscriptionInitial());

  Future<void> load(String userId) async {
    emit(SubscriptionLoading());
    try {
      final plans = await repository.getAvailablePlans();
      final userSub = await repository.loadUserSubscription(userId);
      emit(SubscriptionLoaded(plans, userSub));
    } catch (e) {
      emit(SubscriptionError("Failed to load subscription info"));
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan = plan;
    emit(SubscriptionPlanSelected(plan));
  }

  Future<void> purchase(String userId) async {
    if (selectedPlan == null) {
      emit(SubscriptionError("No plan selected"));
      return;
    }
    emit(SubscriptionBuying());
    try {
      await repository.buySubscription(userId, selectedPlan!);
      await load(userId);
      emit(SubscriptionBought());
      selectedPlan = null;
    } catch (e) {
      emit(SubscriptionError("Purchase failed: $e"));
    }
  }

  Future<void> restore() async {
    emit(SubscriptionLoading());
    try {
      await repository.restorePurchases();
      emit(SubscriptionBought());
    } catch (e) {
      emit(SubscriptionError("Restore failed"));
    }
  }
}
