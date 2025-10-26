part of 'subscription_cubit.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  SubscriptionLoaded(this.plans);
}

class SubscriptionBuying extends SubscriptionState {
  final SubscriptionPlan plan;
  SubscriptionBuying(this.plan);
}

class SubscriptionBought extends SubscriptionState {
  final SubscriptionPlan plan;
  SubscriptionBought(this.plan);
}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}
