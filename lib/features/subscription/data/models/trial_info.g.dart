// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trial_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrialInfo _$TrialInfoFromJson(Map<String, dynamic> json) => TrialInfo(
  startDate: TrialInfo._dateFromJson((json['startDate'] as num?)?.toInt()),
  durationDays: (json['durationDays'] as num?)?.toInt() ?? 7,
);

Map<String, dynamic> _$TrialInfoToJson(TrialInfo instance) => <String, dynamic>{
  'startDate': TrialInfo._dateToJson(instance.startDate),
  'durationDays': instance.durationDays,
};
