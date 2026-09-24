import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  
  static ThemeData createTheme(AppConfig config) {
    final primary = hexToColor(config.primaryColorHex);
    final colorScheme = ColorScheme.fromSeed(seedColor: primary);
    // Material3's default type scale for this ColorScheme - used as the
    // base so swapping in the brand font only changes the font family,
    // not the sizes/weights every screen already assumes.
    final materialTextTheme = ThemeData(colorScheme: colorScheme, useMaterial3: true).textTheme;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutreBlanc,
      // Brand body font, applied app-wide - each white-label flavor picks
      // its own via AppConfig.bodyFontFamily (any Google Fonts family
      // name), instead of every brand sharing one hardcoded font.
      textTheme: GoogleFonts.getTextTheme(config.bodyFontFamily, materialTextTheme),
      extensions: [
        AppBrandTheme(
          surfaceBg: hexToColor(config.surfaceBgHex),
          surfaceBorder: hexToColor(config.surfaceBorderHex),
          divider: hexToColor(config.dividerHex),
          alertBg: hexToColor(config.alertBgHex),
          alertBorder: hexToColor(config.alertBorderHex),
          alertFg: hexToColor(config.alertFgHex),
          statusSuccess: hexToColor(config.statusSuccessHex),
          statusSuccessBg: hexToColor(config.statusSuccessBgHex),
          statusWarning: hexToColor(config.statusWarningHex),
          statusDanger: hexToColor(config.statusDangerHex),
          statusDangerBg: hexToColor(config.statusDangerBgHex),
          statusInfo: hexToColor(config.statusInfoHex),
          statusComplete: hexToColor(config.statusCompleteHex),
          // Hero card: the brand accent mixed into dark bases, so every
          // flavor gets its own tint without a per-flavor config value.
          heroBgStart: Color.lerp(primary, AppColors.heroBaseDeep, 0.84)!,
          heroBgMid: Color.lerp(primary, AppColors.heroBase, 0.68)!,
          heroBgEnd: Color.lerp(primary, AppColors.heroBaseSoft, 0.48)!,
          heroGlow: Color.lerp(primary, AppColors.neutreBlanc, 0.12)!,
          chartLine: Color.lerp(
            hexToColor(config.surfaceBorderHex),
            AppColors.chartWarmBase,
            0.7,
          )!,
          displayTextStyle: GoogleFonts.getFont(config.displayFontFamily, fontWeight: FontWeight.w800),
          moneyTextStyle: GoogleFonts.getFont(
            config.monoFontFamily,
            fontWeight: FontWeight.w700,
          ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: AppColors.neutreBlanc,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.neutreBlanc,
          shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColors.neutreBlanc,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withOpacity(0.3),
        selectionHandleColor: primary,
      ),
    );
  }

  /// Parses a '#RRGGBB' (or 'RRGGBB') brand color into a Color. Public so
  /// widgets that need the raw brand accent (not the Material3 tonal
  /// ColorScheme.primary derived from it) can reuse the same parsing logic
  /// instead of duplicating it.
  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
