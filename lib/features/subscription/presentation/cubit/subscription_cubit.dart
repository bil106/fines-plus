import 'package:fines_plus/features/subscription/data/models/user_subscription.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final PurchaseCubit purchaseCubit;
  final ISubscriptionRepository repository;

  SubscriptionPlan? selectedPlan;

  SubscriptionCubit({required this.purchaseCubit, required this.repository}) : super(SubscriptionInitial());

  Future<void> load(String ownerId) async {
    emit(SubscriptionLoading());
    try {
      final plans = await repository.getAvailablePlans();
      final userSub = await repository.loadUserSubscription(ownerId);
      emit(SubscriptionLoaded(plans, userSub));
    } catch (_) {
      emit(SubscriptionError("Failed to load subscription info"));
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan = plan;
    emit(SubscriptionPlanSelected(plan));
  }

  Future<void> purchase() async {
    if (selectedPlan == null) {
      emit(SubscriptionError("No plan selected"));
      return;
    }

    emit(SubscriptionBuying());

    try {
      await purchaseCubit.buy(selectedPlan!);
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
    } catch (_) {
      emit(SubscriptionError("Restore failed"));
    }
  }
}

