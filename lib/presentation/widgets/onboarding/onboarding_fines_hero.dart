import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_entrance.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_fine_card.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_fly_in.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_illustration.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_loop.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_traffic_light.dart';
import 'package:flutter/material.dart';

/// Onboarding page 3 (штрафи): the traffic stop with a working traffic
/// light, and two fine blanks dropping under the picture.
class OnboardingFinesHero extends StatelessWidget {
  const OnboardingFinesHero({
    super.key,
    required this.entrance,
    required this.isActive,
    required this.accent,
  });

  final Animation<double> entrance;
  final bool isActive;
  final Color accent;

  // onboarding_fines.jpg is 688x780; shown 224 tall to leave room for the
  // blanks below it.
  static const _picture = Size(224 * 688 / 780, 224);

  @override
  Widget build(BuildContext context) {
    final grn = S.of(context).grn;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        OnboardingEntrance(
          animation: entrance,
          begin: 0,
          end: 0.45,
          scaleFrom: 0.96,
          child: SizedBox.fromSize(
            size: _picture,
            child: Stack(
              children: [
                OnboardingIllustration(
                  assetPath: 'assets/images/onboarding_fines.jpg',
                  width: _picture.width,
                  height: _picture.height,
                ),
                OnboardingLoop(
                  duration: const Duration(milliseconds: 3200),
                  isActive: isActive,
                  builder: (context, loop) => OnboardingTrafficLight(
                    loop: loop,
                    pictureSize: _picture,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: -6,
          top: 186,
          child: OnboardingFlyIn(
            animation: entrance,
            begin: 0.3,
            end: 0.72,
            from: const Offset(0, -90),
            turns: -7 / 360,
            child: OnboardingFineCard(
              violation: S.of(context).onboarding_demo_fine_parking,
              amount: '340 $grn',
              accent: accent,
            ),
          ),
        ),
        Positioned(
          left: 128,
          top: 198,
          child: OnboardingFlyIn(
            animation: entrance,
            begin: 0.4,
            end: 0.82,
            from: const Offset(0, -90),
            turns: 5 / 360,
            child: OnboardingFineCard(
              violation: S.of(context).onboarding_demo_fine_speeding,
              amount: '510 $grn',
              accent: accent,
            ),
          ),
        ),
      ],
    );
  }
}
