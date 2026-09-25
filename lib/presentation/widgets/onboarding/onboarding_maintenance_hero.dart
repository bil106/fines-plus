import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_demo_card.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_entrance.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_glare_painter.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_loop.dart';
import 'package:flutter/material.dart';

/// Onboarding page 1 (ТО): the maintenance badge with a highlight sweeping
/// round its rim, and an inspection reminder popping up underneath.
class OnboardingMaintenanceHero extends StatelessWidget {
  const OnboardingMaintenanceHero({
    super.key,
    required this.entrance,
    required this.isActive,
  });

  final Animation<double> entrance;
  final bool isActive;

  static const _badgeSize = 224.0;
  static const _chipTop = 214.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        OnboardingEntrance(
          animation: entrance,
          begin: 0,
          end: 0.45,
          scaleFrom: 0.96,
          child: SizedBox.square(
            dimension: _badgeSize,
            child: OnboardingLoop(
              duration: const Duration(milliseconds: 2600),
              isActive: isActive,
              builder: (context, loop) => CustomPaint(
                foregroundPainter: OnboardingGlarePainter(rotation: loop),
                child: Image.asset(
                  'assets/images/maintenance_bg.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: _chipTop,
          child: OnboardingEntrance(
            animation: entrance,
            begin: 0.4,
            end: 0.75,
            curve: Curves.easeOutBack,
            riseBy: 10,
            scaleFrom: 0.9,
            child: OnboardingDemoCard(
              borderRadius: AppBorders.radius50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 16,
                    color: context.brandTheme.statusSuccess,
                  ),
                  AppSpacers.horizontalSmallMedium,
                  Text(
                    S.of(context).onboarding_demo_inspection,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
