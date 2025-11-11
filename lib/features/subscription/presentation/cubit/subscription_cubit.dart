import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/subscription/data/datasources/load_user_subscription_usecase.dart';
import 'package:fines_plus/features/subscription/data/datasources/save_trial_info_usecase.dart';
import 'package:fines_plus/features/subscription/data/models/subscription_status.dart';
import 'package:fines_plus/features/subscription/data/models/trial_info.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/features/subscription/domain/usecases/buy_subscription.dart';
import 'package:fines_plus/features/subscription/domain/usecases/get_available_plans.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetAvailablePlansUseCase getPlans;
  final BuySubscriptionUseCase buySubscription;
  final LoadUserSubscriptionUseCase loadUser;
  final SaveTrialInfoUseCase saveTrial;
SubscriptionPlan? selectedPlan;
  SubscriptionCubit(this.getPlans, this.buySubscription, this.loadUser, this.saveTrial) : super(SubscriptionInitial());

 Future<void> load(userId) async {
    if (kDebugMode) {
      print("SUB: start load");
    }
    emit(SubscriptionLoading());
    try {
      final plans = await getPlans();
      if (kDebugMode) {
        print("SUB: plans loaded = ${plans.length}");
      }

      final userSub = await loadUser(userId);
      if (kDebugMode) {
        print("SUB: userSub loaded = ${userSub.status} / trial=${userSub.trialInfo}");
      }

      emit(SubscriptionLoaded(plans, userSub.status, userSub.trialInfo));
      if (kDebugMode) {
        print("SUB: emit loaded");
      }
    } catch (e, st) {
      if (kDebugMode) {
        print("SUB ERROR: $e\n$st");
      }
      emit(SubscriptionError("Failed to load subscription info"));
    }
  }


 
  Future<void> startTrial(String userId) async {
    final trial = TrialInfo(startDate: DateTime.now(), durationDays: 7);

   await saveTrial(userId, trial);

  
    await load(userId);

  
    emit(SubscriptionTrialStarted());
  }

  
  Future<void> purchase(String userId, SubscriptionPlan plan) async {
    emit(SubscriptionBuying());
   try {
      await buySubscription(userId, plan);
      await load(userId);
      emit(SubscriptionBought());
    } catch (e) {
      emit(SubscriptionError("Purchase failed"));
    }
  }
  void selectPlan(SubscriptionPlan plan) {
    selectedPlan = plan;
   
    emit(SubscriptionPlanSelected(plan));
  }

 
  Future<void> finishPurchase(String userId) async {
    if (selectedPlan == null) {
      emit(SubscriptionError(S.current.no_plan_selected));
      return;
    }

    emit(SubscriptionBuying());
    try {
      await buySubscription(userId, selectedPlan!);
      await load(userId); 
      emit(SubscriptionBought());
      selectedPlan = null; 
    } catch (e) {
      emit(SubscriptionError("Purchase failed: $e"));
    }
  }
}
