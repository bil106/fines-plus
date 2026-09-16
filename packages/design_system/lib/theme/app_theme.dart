import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

export 'app_text_theme.dart';

final appLightTheme = ThemeData(
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.white,
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
  scaffoldBackgroundColor: AppColors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((status) {
        var color = AppColors.energyBlue;
        if (status.contains(WidgetState.disabled)) {
          color = AppColors.energyBlue.withValues(alpha: .5);
        }
        return color;
      }),
      foregroundColor: const WidgetStatePropertyAll(AppColors.white),
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

/// Semantic text-style roles for the app. Each getter's visual value
/// (size/weight/color) is unchanged from the pre-consolidation names it
/// replaces — this pass only cut duplicate/dead getters and gave the
/// survivors clear names; it does not attempt to unify near-identical
/// sizes/weights, since that would actually change how some screens look.
extension AppTextTheme on TextTheme {
  // --- Screen/section headers ---
  TextStyle get title => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 36,
      );
  TextStyle get heroHeading => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 30,
      );
  TextStyle get sectionHeading => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      );
  TextStyle get subheading => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      );
  TextStyle get headingRegular => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get headingAccent => const TextStyle(
        color: AppColors.blue700,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get carNumber => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: AppColors.black87,
      );
  TextStyle get historyText => const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.black87);
  TextStyle get noFinesText => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.black87,
      );

  // --- Body / labels ---
  TextStyle get subtitleText => const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.black);
  TextStyle get bodySoft => const TextStyle(
        color: AppColors.black87,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get bodyMuted => const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get labelStrong => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      );
  TextStyle get bodyStrong => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      );
  TextStyle get bodyEmphasis => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      );
  TextStyle get captionStrong => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
  TextStyle get caption => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 13,
      );
  TextStyle get captionMuted => const TextStyle(
        color: AppColors.grey400,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      );
  TextStyle get hintText => const TextStyle(
        color: AppColors.grey400,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get hintCaption => const TextStyle(
        color: AppColors.grey400,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      );

  // --- Status / accent ---
  TextStyle get statusPositive => const TextStyle(
        color: AppColors.green,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      );
  TextStyle get statusAccent => const TextStyle(
        color: AppColors.blue700,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      );

  // --- On dark / colored backgrounds ---
  TextStyle get buttonText => const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      );
  TextStyle get whiteBody => const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get whiteCaption => const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      );
}
