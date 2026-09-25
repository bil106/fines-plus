import 'package:flutter/material.dart';

/// Fades and lifts [child] in over the [begin]..[end] slice of a shared
/// onboarding [animation], so several elements can be staggered off one
/// controller. [scaleFrom] < 1 adds a small "pop" (use with a back curve).
class OnboardingEntrance extends StatelessWidget {
  const OnboardingEntrance({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.curve = Curves.easeOutCubic,
    this.riseBy = 16,
    this.scaleFrom = 1,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Curve curve;
  final double riseBy;
  final double scaleFrom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = Interval(begin, end, curve: curve);
    final fade = Interval(begin, end, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final lift = progress.transform(animation.value);
        return Opacity(
          opacity: fade.transform(animation.value).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, riseBy * (1 - lift)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * lift,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
