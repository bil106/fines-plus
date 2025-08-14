
import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

final tuiLightTheme = ThemeData(
  fontFamily: 'AppTypeLight', 
  package: 'design_system',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.neutreBlanc,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedLabelStyle: TextStyle(
      fontSize: 10,
      overflow: TextOverflow.visible,
      height: 1.2,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 10,
      overflow: TextOverflow.visible,
      height: 1.2,
    ),
  ),
  scaffoldBackgroundColor: AppColors.neutreBlanc,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((status) {
        var color = AppColors.energyBlue;
        if (status.contains(WidgetState.disabled)) {
          color = AppColors.energyBlue.withValues(alpha: .5);
        }
        return color;
      }),
      foregroundColor: WidgetStatePropertyAll(AppColors.neutreBlanc),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          height: 22 / 18,
          letterSpacing: 0,
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 20 / 14,
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      height: 22 / 16,
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 18,
      height: 22 / 18,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 22,
      height: 28 / 22,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Ambit', 
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 30 / 24,
    ),
    labelMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      height: 1.0,
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 10 / 12,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Ambit', 
      fontWeight: FontWeight.w700,
      fontSize: 18,
      height: 24 / 18,
    ),
  ),
);

