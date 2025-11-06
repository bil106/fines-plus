part of 'subscription_cubit.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  final SubscriptionStatus status;
  final TrialInfo? trialInfo;

  SubscriptionLoaded(this.plans, this.status, this.trialInfo);
}

class SubscriptionBuying extends SubscriptionState {}

class SubscriptionBought extends SubscriptionState {}

class SubscriptionTrialStarted extends SubscriptionState {}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}
class SubscriptionPlanSelected extends SubscriptionState {
  final SubscriptionPlan plan;
  SubscriptionPlanSelected(this.plan);
}
