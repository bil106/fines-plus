import 'package:fines_plus/presentation/widgets/onboarding/onboarding_entrance.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_fly_in.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_form_sheet.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_illustration.dart';
import 'package:fines_plus/presentation/widgets/onboarding/onboarding_policy_sheet.dart';
import 'package:flutter/material.dart';

/// Onboarding page 2 (страховка): the car under the umbrella, with the
/// policy and its form fanning out to the sides.
class OnboardingInsuranceHero extends StatelessWidget {
  const OnboardingInsuranceHero({
    super.key,
    required this.entrance,
    required this.accent,
  });

  final Animation<double> entrance;
  final Color accent;

  static const _size = 260.0;

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
          child: const OnboardingIllustration(
            assetPath: 'assets/images/onboarding_insurance.jpg',
            width: _size,
            height: _size,
          ),
        ),
        Positioned(
          left: -22,
          top: 150,
          child: OnboardingFlyIn(
            animation: entrance,
            begin: 0.28,
            end: 0.7,
            from: const Offset(70, 10),
            turns: -8 / 360,
            scaleFrom: 0.7,
            child: OnboardingPolicySheet(accent: accent),
          ),
        ),
        Positioned(
          left: 178,
          top: 138,
          child: OnboardingFlyIn(
            animation: entrance,
            begin: 0.34,
            end: 0.76,
            from: const Offset(-70, 10),
            turns: 7 / 360,
            scaleFrom: 0.7,
            child: OnboardingFormSheet(accent: accent),
          ),
        ),
      ],
    );
  }
}
