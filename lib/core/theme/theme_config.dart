import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/material.dart';

class ThemeConfig {
  
  static ThemeData createTheme(AppConfig config) {
    final primary = hexToColor(config.primaryColorHex);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.neutreBlanc,
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
