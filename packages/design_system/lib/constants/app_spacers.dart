import 'package:flutter/material.dart';

abstract final class AppSpacers {
  // Vertical spacers
  static const verticalLSmall = SizedBox(height: 2);
  static const verticalXSmall = SizedBox(height: 4);
  static const verticalSmall = SizedBox(height: 6);
  static const verticalSmallMedium = SizedBox(height: 8);
  static const verticalMedium = SizedBox(height: 12);
  static const verticalMediumLarge = SizedBox(height: 16);
  static const verticalLarge = SizedBox(height: 20);
  static const verticalLargeXL = SizedBox(height: 24);
  static const verticalXLarge = SizedBox(height: 26);
  static const verticalXXLarge = SizedBox(height: 30);
  static const verticalXXXLarge = SizedBox(height: 32);
  static const verticalHuge = SizedBox(height: 40);
  static const verticalHugeXL = SizedBox(height: 44);
  static const verticalMassive = SizedBox(height: 50);
  static const verticalMaxMassive = SizedBox(height: 80);
  static const verticalGigantic = SizedBox(height: 120);
  static const verticalXGigantic = SizedBox(height: 150);
  static const verticalXXGigantic = SizedBox(height: 195);
  static const verticalMaxGigantic = SizedBox(height: 250);

  // Horizontal spacers
  static const horizontalXSmall = SizedBox(width: 4);
  static const horizontalSmall = SizedBox(width: 6);
  static const horizontalSmallMedium = SizedBox(width: 8);
  static const horizontalMedium = SizedBox(width: 12);
  static const horizontalMediumLarge = SizedBox(width: 16);
  static const horizontalLarge = SizedBox(width: 20);
  static const horizontalLargeXL = SizedBox(width: 24);
  static const horizontalXLarge = SizedBox(width: 26);
  static const horizontalXXLarge = SizedBox(width: 30);
  static const horizontalXXXLarge = SizedBox(width: 32);
  static const horizontalHuge = SizedBox(width: 40);
  static const horizontalMassive = SizedBox(width: 50);
  static const horizontalXMassive = SizedBox(width: 56);
  static const horizontalXXMassive = SizedBox(width: 78);
  static const horizontalXXHuge = SizedBox(width: 100);
  static const horizontalXXGigantic = SizedBox(height: 175);
}

abstract final class AppLoaders {
  static const small = SizedBox(
    width: 24,
    height: 24,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  static const medium = SizedBox(
    width: 40,
    height: 40,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
