// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSubscription _$UserSubscriptionFromJson(Map<String, dynamic> json) =>
    UserSubscription(
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      trialInfo: json['trialInfo'] == null
          ? null
          : TrialInfo.fromJson(json['trialInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserSubscriptionToJson(UserSubscription instance) =>
    <String, dynamic>{
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'trialInfo': instance.trialInfo,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.none: 'none',
  SubscriptionStatus.trialActive: 'trialActive',
  SubscriptionStatus.trialEnded: 'trialEnded',
  SubscriptionStatus.subscribed: 'subscribed',
};
