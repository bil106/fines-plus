import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_demo_card.dart';
import 'package:flutter/material.dart';

/// Left sheet flying out of the insurance picture: the policy's name,
/// number and validity (demo data).
class OnboardingPolicySheet extends StatelessWidget {
  const OnboardingPolicySheet({super.key, required this.accent});

  final Color accent;

  static const width = 104.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final small = textTheme.bodySmall?.copyWith(
      fontSize: 10,
      color: AppColors.textSecondary,
    );
    return OnboardingDemoCard(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 20, color: accent),
          AppSpacers.verticalXSmall,
          Text(
            S.of(context).insurance_osago,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          AppSpacers.verticalXSmall,
          Text(S.of(context).onboarding_demo_policy_number, style: small),
          AppSpacers.verticalXSmall,
          Text(
            S.of(context).onboarding_demo_policy_valid_until,
            style: small?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.brandTheme.statusSuccess,
            ),
          ),
        ],
      ),
    );
  }
}
