
import 'package:fines_plus/config/app_config.dart';
import 'package:flutter/material.dart';


class ThemeConfig {
  static ThemeData createTheme(AppConfig config) {
    final primary = _hexToColor(config.primaryColorHex);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primary, foregroundColor: Colors.white),
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

  static Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
