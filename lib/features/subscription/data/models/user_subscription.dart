import 'package:json_annotation/json_annotation.dart';

import 'subscription_status.dart';

part 'user_subscription.g.dart';

@JsonSerializable()
class UserSubscription {
  final SubscriptionStatus status;
  final DateTime? subscriptionEndDate;
  final DateTime? trialEndsAt;

  UserSubscription({required this.status, this.subscriptionEndDate, this.trialEndsAt});

  factory UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$UserSubscriptionToJson(this);
}
