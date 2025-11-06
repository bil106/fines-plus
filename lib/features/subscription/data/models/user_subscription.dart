import 'package:json_annotation/json_annotation.dart';
import 'trial_info.dart';
import 'subscription_status.dart';

part 'user_subscription.g.dart';

@JsonSerializable()
class UserSubscription {
  final SubscriptionStatus status;
  final TrialInfo? trialInfo;

  UserSubscription({required this.status, this.trialInfo});

  factory UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$UserSubscriptionToJson(this);
}
