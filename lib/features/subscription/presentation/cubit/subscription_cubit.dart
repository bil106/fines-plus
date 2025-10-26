import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/features/subscription/domain/usecases/buy_subscription.dart';
import 'package:fines_plus/features/subscription/domain/usecases/get_available_plans.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetAvailablePlansUseCase getPlans;
  final BuySubscriptionUseCase buySubscription;

  SubscriptionCubit(this.getPlans, this.buySubscription) : super(SubscriptionInitial());

  Future<void> loadPlans() async {
    emit(SubscriptionLoading());
    try {
      final plans = await getPlans();
      emit(SubscriptionLoaded(plans));
    } catch (e) {
      emit(SubscriptionError("Failed to load plans"));
    }
  }

  Future<void> purchase(String userId, SubscriptionPlan plan) async {
    emit(SubscriptionBuying(plan));
    try {
      await buySubscription(userId, plan);
      emit(SubscriptionBought(plan));
    } catch (e) {
      emit(SubscriptionError("Purchase failed"));
    }
  }
}
