import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/vehicle/data/car_make_logos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders the bundled logo for [make] (svg or png, whichever the asset
/// is), or a generic car icon if [make] is empty or has no bundled logo.
class CarMakeLogo extends StatelessWidget {
  final String make;
  final double size;
  final Color? fallbackColor;

  const CarMakeLogo({super.key, required this.make, this.size = 28, this.fallbackColor});

  @override
  Widget build(BuildContext context) {
    final asset = carMakeLogos[make];
    if (asset == null) {
      return Icon(Icons.directions_car, size: size, color: fallbackColor ?? AppColors.grey400);
    }

    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(asset, width: size, height: size, fit: BoxFit.contain);
    }
    return Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
  }
}
