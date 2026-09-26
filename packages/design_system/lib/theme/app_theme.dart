import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

export 'app_text_theme.dart';

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
  TextStyle get black54fs18 => const TextStyle(
        color: AppColors.black54,
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
  TextStyle get red14W400 => const TextStyle(
        color: AppColors.red,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      );
  TextStyle get black28W600 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 28,
      );
  TextStyle get black18W600 => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: 18,
      );
  TextStyle get black30bold => const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 30,
      );
  TextStyle get hintAnalitText => const TextStyle(
        color: AppColors.neutreGrey,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      );
  TextStyle get historyText => const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.black87);
  TextStyle get subtitleText => const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.black);
}
