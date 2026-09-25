import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// White floating card used by the onboarding illustrations (reminder chip,
/// policy sheets, fine blanks) - one surface so they all read as the same
/// kind of "app UI peeking out of the picture".
class OnboardingDemoCard extends StatelessWidget {
  const OnboardingDemoCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = AppBorders.radius16,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: borderRadius,
        border: Border.all(
          color: context.brandTheme.surfaceBorder,
          width: AppBorders.widthThin,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
