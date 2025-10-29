// GENERATED CODE - DO NOT MODIFY BY HAND

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
);

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'brandName': instance.brandName,
  'primaryColorHex': instance.primaryColorHex,
  'logoAssetPath': instance.logoAssetPath,
  'supportEmail': instance.supportEmail,
  'phoneNumber': instance.phoneNumber,
  'viberNumber': instance.viberNumber,
};
