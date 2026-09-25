import 'package:core_utils/formatters/plate_market.dart';
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

  /// Whether the Ukraine-specific fines-check feature (the MVS portal, see
  /// MvsFinesWebView) is available for this brand. It talks to a Ukrainian
  /// government portal, so it has no equivalent outside UA.
  /// Defaults to true so existing configs (finesplus, autodosje, carpapers)
  /// keep today's behavior unchanged.
  @JsonKey(defaultValue: true)
  final bool finesCheckEnabled;

  /// Per-brand legal links. Null falls back to the global Env.termsUrl /
  /// Env.privacyPolicyUrl (see env/env.dart) so existing configs still work.
  final String? termsUrl;
  final String? privacyPolicyUrl;

  /// Optional per-brand overrides for specific ARB-driven strings, keyed by
  /// the same key used in intl_*.arb (e.g. "garage_setup_subtitle"). Lets
  /// two brands that share a language (e.g. two UA brands both showing
  /// Ukrainian) use different wording for the *same* string, without forking
  /// the whole localization table. Looked up via brandCopy() in
  /// core/config/brand_copy.dart - see docs/white-label-playbook.md for the
  /// pattern and which keys are currently wired up. Null/absent key falls
  /// back to the shared S.of(context) string, so existing configs need no
  /// changes.
  final Map<String, String>? copyOverrides;

  /// Per-brand theme tokens for the redesigned dashboard-style screens (see
  /// packages/design_system/lib/theme/app_brand_theme.dart). Every field
  /// defaults to the values the Fines+OS mockup was designed with, so an
  /// existing config that doesn't set them looks exactly as it does today -
  /// a brand only needs to add a key here to actually override one.
  @JsonKey(defaultValue: '#F5F3ED')
  final String surfaceBgHex;
  @JsonKey(defaultValue: '#E6E1D2')
  final String surfaceBorderHex;
  @JsonKey(defaultValue: '#E7E3D6')
  final String dividerHex;
  @JsonKey(defaultValue: '#FBE1E1')
  final String alertBgHex;
  @JsonKey(defaultValue: '#F3B9B9')
  final String alertBorderHex;
  @JsonKey(defaultValue: '#B23A3E')
  final String alertFgHex;
  @JsonKey(defaultValue: '#198B49')
  final String statusSuccessHex;
  @JsonKey(defaultValue: '#DEF4E6')
  final String statusSuccessBgHex;
  @JsonKey(defaultValue: '#BA8700')
  final String statusWarningHex;
  @JsonKey(defaultValue: '#BE3540')
  final String statusDangerHex;
  @JsonKey(defaultValue: '#FBE0E2')
  final String statusDangerBgHex;
  @JsonKey(defaultValue: '#00A99A')
  final String statusInfoHex;
  @JsonKey(defaultValue: '#79B58A')
  final String statusCompleteHex;

  /// Google Fonts family names (see https://fonts.google.com/) - resolved
  /// at runtime via GoogleFonts.getFont(), so any family listed there can
  /// be dropped into a brand's config without a code change.
  @JsonKey(defaultValue: 'Big Shoulders Display')
  final String displayFontFamily;
  @JsonKey(defaultValue: 'Manrope')
  final String bodyFontFamily;
  @JsonKey(defaultValue: 'JetBrains Mono')
  final String monoFontFamily;

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
    this.copyOverrides,
    this.surfaceBgHex = '#F5F3ED',
    this.surfaceBorderHex = '#E6E1D2',
    this.dividerHex = '#E7E3D6',
    this.alertBgHex = '#FBE1E1',
    this.alertBorderHex = '#F3B9B9',
    this.alertFgHex = '#B23A3E',
    this.statusSuccessHex = '#1E8A4C',
    this.statusSuccessBgHex = '#E3F5E9',
    this.statusWarningHex = '#B25E00',
    this.statusDangerHex = '#B23A3E',
    this.statusDangerBgHex = '#FBE1E1',
    this.statusInfoHex = '#00A99A',
    this.statusCompleteHex = '#79B58A',
    this.displayFontFamily = 'Big Shoulders Display',
    this.bodyFontFamily = 'Manrope',
    this.monoFontFamily = 'JetBrains Mono',
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);

  /// Plate format/badge rules for [market].
  PlateMarket get plateMarket => PlateMarket.fromCode(market);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}
