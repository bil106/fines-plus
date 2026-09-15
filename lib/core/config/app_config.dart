import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig {
  final String brandName;
  final String primaryColorHex;
  final String logoAssetPath;
  final String supportEmail;
  final String phoneNumber;
  final String viberNumber;

  /// Market/region this brand targets (e.g. 'UA', 'US', 'ES'). Optional for
  /// backward compatibility with existing configs — defaults to 'UA'.
  @JsonKey(defaultValue: 'UA')
  final String market;

  /// Whether the Ukraine-specific automated fines-check feature (see
  /// core/config/fines_api.dart) is available for this brand. It talks to a
  /// Ukrainian government portal, so it has no equivalent outside UA.
  /// Defaults to true so existing configs (finesplus, autolux, fastcar) keep
  /// today's behavior unchanged.
  @JsonKey(defaultValue: true)
  final bool finesCheckEnabled;

  /// Per-brand legal links. Null falls back to the global Env.termsUrl /
  /// Env.privacyPolicyUrl (see env/env.dart) so existing configs still work.
  final String? termsUrl;
  final String? privacyPolicyUrl;

  const AppConfig({
    required this.brandName,
    required this.primaryColorHex,
    required this.logoAssetPath,
    required this.supportEmail,
    required this.phoneNumber,
    required this.viberNumber,
    this.market = 'UA',
    this.finesCheckEnabled = true,
    this.termsUrl,
    this.privacyPolicyUrl,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}
