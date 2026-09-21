import 'package:flutter/material.dart';
import 'package:design_system/colors/app_colors.dart';

/// Per-brand design tokens layered on top of Material's ColorScheme/
/// TextTheme. Populated from AppConfig by ThemeConfig.createTheme (see
/// fines_plus/core/theme/theme_config.dart) so every white-label flavor can
/// set its own surface/alert colors and font families through its
/// `assets/config/<flavor>.json` instead of every brand sharing one hardcoded
/// look.
///
/// Read via `context.brandTheme.<token>` (extension below), not by
/// hardcoding a color/font in a widget.
class AppBrandTheme extends ThemeExtension<AppBrandTheme> {
  const AppBrandTheme({
    required this.surfaceBg,
    required this.surfaceBorder,
    required this.divider,
    required this.alertBg,
    required this.alertBorder,
    required this.alertFg,
    this.statusSuccess = AppColors.green,
    this.statusSuccessBg = AppColors.greenAccent,
    this.statusWarning = AppColors.orange,
    this.statusDanger = AppColors.red,
    this.statusDangerBg = AppColors.lightRed,
    this.statusInfo = AppColors.cm,
    this.statusComplete = AppColors.lightGreen,
    required this.displayTextStyle,
    required this.moneyTextStyle,
  });

  /// Warm neutral page background for the redesigned dashboard-style
  /// screens (distinct from the app's older shared scaffold background).
  final Color surfaceBg;

  /// Border color for flat, borderless-shadow cards on those screens.
  final Color surfaceBorder;

  /// Divider color between list rows on those screens.
  final Color divider;

  /// Unpaid-fines alert card background/border/foreground.
  final Color alertBg;
  final Color alertBorder;
  final Color alertFg;

  /// Semantic colors shared by reminders, garage health, and fines.
  final Color statusSuccess;
  final Color statusSuccessBg;
  final Color statusWarning;
  final Color statusDanger;
  final Color statusDangerBg;
  final Color statusInfo;
  final Color statusComplete;

  /// Base style for large display text (e.g. the plate number). Callers
  /// set fontSize/color via copyWith - this only fixes the font family and
  /// weight.
  final TextStyle displayTextStyle;

  /// Base style for money figures (tabular mono digits). Merge this onto a
  /// TextTheme style to keep that style's size/height:
  /// `textTheme.headlineMedium?.merge(context.brandTheme.moneyTextStyle)`.
  final TextStyle moneyTextStyle;

  @override
  AppBrandTheme copyWith({
    Color? surfaceBg,
    Color? surfaceBorder,
    Color? divider,
    Color? alertBg,
    Color? alertBorder,
    Color? alertFg,
    Color? statusSuccess,
    Color? statusSuccessBg,
    Color? statusWarning,
    Color? statusDanger,
    Color? statusDangerBg,
    Color? statusInfo,
    Color? statusComplete,
    TextStyle? displayTextStyle,
    TextStyle? moneyTextStyle,
  }) {
    return AppBrandTheme(
      surfaceBg: surfaceBg ?? this.surfaceBg,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      divider: divider ?? this.divider,
      alertBg: alertBg ?? this.alertBg,
      alertBorder: alertBorder ?? this.alertBorder,
      alertFg: alertFg ?? this.alertFg,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusSuccessBg: statusSuccessBg ?? this.statusSuccessBg,
      statusWarning: statusWarning ?? this.statusWarning,
      statusDanger: statusDanger ?? this.statusDanger,
      statusDangerBg: statusDangerBg ?? this.statusDangerBg,
      statusInfo: statusInfo ?? this.statusInfo,
      statusComplete: statusComplete ?? this.statusComplete,
      displayTextStyle: displayTextStyle ?? this.displayTextStyle,
      moneyTextStyle: moneyTextStyle ?? this.moneyTextStyle,
    );
  }

  @override
  AppBrandTheme lerp(ThemeExtension<AppBrandTheme>? other, double t) {
    if (other is! AppBrandTheme) return this;
    // These are brand-identity tokens, not animated values - snap instead
    // of interpolating colors/fonts mid-transition.
    return t < 0.5 ? this : other;
  }
}

extension AppBrandThemeGetter on BuildContext {
  AppBrandTheme get brandTheme => Theme.of(this).extension<AppBrandTheme>()!;
}
