import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_demo_card.dart';
import 'package:flutter/material.dart';

/// A fine blank dropping under the traffic scene: violation, amount and a
/// (decorative, non-tappable) "pay" pill.
class OnboardingFineCard extends StatelessWidget {
  const OnboardingFineCard({
    super.key,
    required this.violation,
    required this.amount,
    required this.accent,
  });

  final String violation;
  final String amount;
  final Color accent;

  static const width = 132.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return OnboardingDemoCard(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            violation,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacers.verticalLSmall,
          Text(
            amount,
            style: context.brandTheme.displayTextStyle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
              color: context.brandTheme.statusDanger,
            ),
          ),
          AppSpacers.verticalXSmall,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: AppBorders.radius50,
            ),
            child: Text(
              S.of(context).pay,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.neutreBlanc,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
