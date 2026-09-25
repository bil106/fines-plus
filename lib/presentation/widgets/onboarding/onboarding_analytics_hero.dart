import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_bars_painter.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_entrance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Onboarding page 4 (аналітика): a month's expense total counting up over
/// an isometric bar chart that grows in.
class OnboardingAnalyticsHero extends StatelessWidget {
  const OnboardingAnalyticsHero({super.key, required this.entrance});

  final Animation<double> entrance;

  static const _demoTotal = 12480;
  static const _chartTop = 60.0;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    const count = Interval(0.1, 0.6, curve: Curves.easeOutCubic);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        OnboardingEntrance(
          animation: entrance,
          begin: 0,
          end: 0.35,
          child: Column(
            children: [
              Text(
                l10n.onboarding_demo_expenses_title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
              ),
              AnimatedBuilder(
                animation: entrance,
                builder: (context, _) => Text(
                  '${number.format((_demoTotal * count.transform(entrance.value)).round())} ${l10n.grn}',
                  style: context.brandTheme.displayTextStyle.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: _chartTop,
          child: CustomPaint(
            size: OnboardingBarsPainter.designSize,
            painter: OnboardingBarsPainter(progress: entrance),
          ),
        ),
      ],
    );
  }
}
