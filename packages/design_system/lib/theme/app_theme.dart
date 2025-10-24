import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

export 'app_text_theme.dart';

final appLightTheme = ThemeData(
  fontFamily: 'Roboto',
  package: 'design_system',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.neutreBlanc,
    surfaceTintColor: AppColors.transparent,
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
      foregroundColor: const WidgetStatePropertyAll(AppColors.neutreBlanc),
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
      fontWeight: FontWeight.w500,
      fontSize: 20,
      height: 22 / 18,
    ),
    // headlineMedium: TextStyle(
    //   fontWeight: FontWeight.w400,
    //   fontSize: 22,
    //   height: 24 / 22,
    // ),
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
    // displayLarge: TextStyle(
    //   color: AppColors.black,
    //   fontWeight: FontWeight.bold,
    //   fontSize: 36,

    // ),
    titleLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: AppColors.black87,
    ),
    titleMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: AppColors.black87,
    ),
    titleSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: AppColors.black87,
    ),
  ),
);

extension AppTextTheme on TextTheme {
  TextStyle get totalFines => const TextStyle(
        fontSize: 58,
        fontWeight: FontWeight.w600,
        color: AppColors.black87,
      );

  TextStyle get carNumber => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: AppColors.black87,
      );

  TextStyle get fineDate => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: AppColors.black87,
      );

  TextStyle get violationTitle => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.black87,
      );
  TextStyle get title => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 36,
      );
  TextStyle get noFinesText => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.black87,
      );
  TextStyle get buttonText => const TextStyle(
        color: AppColors.neutreBlanc,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      );
  TextStyle get hintText => const TextStyle(
        color: AppColors.neutreGrey,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get black28W400 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get blue28W400 => const TextStyle(
        color: AppColors.blue700,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get black18W400 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get black13W400 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 13,
      );
  TextStyle get grey12W400 => const TextStyle(
        color: AppColors.neutreGrey,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      );
  TextStyle get black16bold => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      );
  TextStyle get black16 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      );
  TextStyle get black14bold => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
  TextStyle get black20bold => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      );
  TextStyle get green20W400 => const TextStyle(
        color: AppColors.green,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      );
  TextStyle get blue20W400 => const TextStyle(
        color: AppColors.blue700,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      );
  TextStyle get black18bold => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      );
  TextStyle get black18W500 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      );
  TextStyle get black8718W400 => const TextStyle(
        color: AppColors.black87,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get white18W400 => const TextStyle(
        color: AppColors.neutreBlanc,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get white14W400 => const TextStyle(
        color: AppColors.neutreBlanc,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      );
  TextStyle get black28W600 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get black30bold => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 30,
      );
  TextStyle get hintAnalitText => const TextStyle(
        color: AppColors.neutreGrey,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get historyText => const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.black87);
  TextStyle get subtitleText => const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.black);
}
