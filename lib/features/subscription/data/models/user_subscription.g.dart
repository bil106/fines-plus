// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSubscription _$UserSubscriptionFromJson(Map<String, dynamic> json) =>
    UserSubscription(
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      subscriptionEndDate: json['subscriptionEndDate'] == null
          ? null
          : DateTime.parse(json['subscriptionEndDate'] as String),
      trialEndsAt: json['trialEndsAt'] == null
          ? null
          : DateTime.parse(json['trialEndsAt'] as String),
    );

Map<String, dynamic> _$UserSubscriptionToJson(UserSubscription instance) =>
    <String, dynamic>{
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'subscriptionEndDate': instance.subscriptionEndDate?.toIso8601String(),
      'trialEndsAt': instance.trialEndsAt?.toIso8601String(),
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.none: 'none',
  SubscriptionStatus.subscribed: 'subscribed',
  SubscriptionStatus.trial: 'trial',
};
