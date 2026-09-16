import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

extension AppTextTheme on TextTheme {
  TextStyle get whiteNormal => const TextStyle(
        fontSize: 24,
        color: AppColors.white,
      );
}
