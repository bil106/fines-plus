import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// A studio-shot illustration on a pure white background (no alpha).
/// Multiplying it by the flavor's surfaceBg turns that white into exactly
/// the screen colour, so the picture has no visible box on any brand, while
/// the glass parts pick up the same tint as if they were see-through.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
  });

  final String assetPath;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      color: context.brandTheme.surfaceBg,
      colorBlendMode: BlendMode.multiply,
    );
  }
}
