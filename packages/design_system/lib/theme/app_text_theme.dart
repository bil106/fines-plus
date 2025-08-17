import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

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
      TextStyle get whiteBigBold => const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: AppColors.neutreBlanc,
      );

 
  TextStyle get whiteNormal => const TextStyle(
        fontSize: 24,
        color: AppColors.neutreBlanc,
      );
}
