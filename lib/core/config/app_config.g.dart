// GENERATED CODE - DO NOT MODIFY BY HAND
//
// NOTE: hand-updated alongside the market/finesCheckEnabled/termsUrl/
// privacyPolicyUrl fields added to AppConfig. Re-run
// `dart run build_runner build --delete-conflicting-outputs` to regenerate
// the canonical version once you can run it locally.

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
  brandName: json['brandName'] as String,
  primaryColorHex: json['primaryColorHex'] as String,
  logoAssetPath: json['logoAssetPath'] as String,
  supportEmail: json['supportEmail'] as String,
  phoneNumber: json['phoneNumber'] as String,
  viberNumber: json['viberNumber'] as String,
  market: json['market'] as String? ?? 'UA',
  finesCheckEnabled: json['finesCheckEnabled'] as bool? ?? true,
  termsUrl: json['termsUrl'] as String?,
  privacyPolicyUrl: json['privacyPolicyUrl'] as String?,
  copyOverrides: (json['copyOverrides'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'brandName': instance.brandName,
  'primaryColorHex': instance.primaryColorHex,
  'logoAssetPath': instance.logoAssetPath,
  'supportEmail': instance.supportEmail,
  'phoneNumber': instance.phoneNumber,
  'viberNumber': instance.viberNumber,
  'market': instance.market,
  'finesCheckEnabled': instance.finesCheckEnabled,
  if (instance.termsUrl != null) 'termsUrl': instance.termsUrl,
  if (instance.privacyPolicyUrl != null) 'privacyPolicyUrl': instance.privacyPolicyUrl,
  if (instance.copyOverrides != null) 'copyOverrides': instance.copyOverrides,
};
