// GENERATED CODE - DO NOT MODIFY BY HAND
//
// NOTE: hand-updated alongside the market/finesCheckEnabled/termsUrl/
// privacyPolicyUrl fields, and again for the surfaceBgHex/surfaceBorderHex/
// dividerHex/alertBgHex/alertBorderHex/alertFgHex/displayFontFamily/
// bodyFontFamily/monoFontFamily brand-theme fields, added to AppConfig.
// Re-run `dart run build_runner build --delete-conflicting-outputs` to
// regenerate the canonical version once you can run it locally.

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
  surfaceBgHex: json['surfaceBgHex'] as String? ?? '#F5F3ED',
  surfaceBorderHex: json['surfaceBorderHex'] as String? ?? '#E6E1D2',
  dividerHex: json['dividerHex'] as String? ?? '#E7E3D6',
  alertBgHex: json['alertBgHex'] as String? ?? '#FBE1E1',
  alertBorderHex: json['alertBorderHex'] as String? ?? '#F3B9B9',
  alertFgHex: json['alertFgHex'] as String? ?? '#B23A3E',
  displayFontFamily: json['displayFontFamily'] as String? ?? 'Big Shoulders Display',
  bodyFontFamily: json['bodyFontFamily'] as String? ?? 'Manrope',
  monoFontFamily: json['monoFontFamily'] as String? ?? 'JetBrains Mono',
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
  'surfaceBgHex': instance.surfaceBgHex,
  'surfaceBorderHex': instance.surfaceBorderHex,
  'dividerHex': instance.dividerHex,
  'alertBgHex': instance.alertBgHex,
  'alertBorderHex': instance.alertBorderHex,
  'alertFgHex': instance.alertFgHex,
  'displayFontFamily': instance.displayFontFamily,
  'bodyFontFamily': instance.bodyFontFamily,
  'monoFontFamily': instance.monoFontFamily,
};
