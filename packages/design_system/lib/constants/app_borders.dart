import 'package:flutter/material.dart';

abstract final class AppBorders {
  // Border radius
  static const radiusSmall = BorderRadius.all(Radius.circular(4));
  static const radiusMedium = BorderRadius.all(Radius.circular(8));
  static const radiusLarge = BorderRadius.all(Radius.circular(12));
  static const radius16 = BorderRadius.all(Radius.circular(16));
  static const radius18 = BorderRadius.all(Radius.circular(18));
  static const radius22 = BorderRadius.all(Radius.circular(22));
  static const radius50 = BorderRadius.all(Radius.circular(50));

  // Border widths
  static const widthThin = 1.0;
  static const widthMedium = 1.5;
  static const widthThick = 2.0;
}
