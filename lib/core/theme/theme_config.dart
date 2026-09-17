import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  
  static ThemeData createTheme(AppConfig config) {
    final primary = hexToColor(config.primaryColorHex);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutreBlanc,
      // Brand body font, applied app-wide - each white-label flavor picks
      // its own via AppConfig.bodyFontFamily (any Google Fonts family
      // name), instead of every brand sharing one hardcoded font.
      textTheme: GoogleFonts.getTextTheme(config.bodyFontFamily),
      extensions: [
        AppBrandTheme(
          surfaceBg: hexToColor(config.surfaceBgHex),
          surfaceBorder: hexToColor(config.surfaceBorderHex),
          divider: hexToColor(config.dividerHex),
          alertBg: hexToColor(config.alertBgHex),
          alertBorder: hexToColor(config.alertBorderHex),
          alertFg: hexToColor(config.alertFgHex),
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
