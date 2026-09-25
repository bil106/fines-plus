import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_demo_card.dart';
import 'package:flutter/material.dart';

/// Right sheet flying out of the insurance picture: a wordless policy form
/// (header, text lines, signature and stamp) - pure illustration.
class OnboardingFormSheet extends StatelessWidget {
  const OnboardingFormSheet({super.key, required this.accent});

  final Color accent;

  static const width = 104.0;
  static const height = 128.0;
  static const _stampSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final lineColor = context.brandTheme.divider;
    return OnboardingDemoCard(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(0.6, 6, accent),
          AppSpacers.verticalSmall,
          _line(0.9, 4, lineColor),
          AppSpacers.verticalSmall,
          _line(0.75, 4, lineColor),
          AppSpacers.verticalSmall,
          _line(0.85, 4, lineColor),
          AppSpacers.verticalSmall,
          _line(0.6, 4, lineColor),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 38, height: 2, color: AppColors.catOther),
              Container(
                width: _stampSize,
                height: _stampSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.7),
                    width: AppBorders.widthThick,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(double widthFactor, double thickness, Color color) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: thickness,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppBorders.radiusSmall,
        ),
      ),
    );
  }
}
