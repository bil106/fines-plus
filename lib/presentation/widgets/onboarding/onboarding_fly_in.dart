import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Brings [child] in from [from] (a pixel offset relative to its resting
/// place) and settles it tilted by [turns], with a slight overshoot - the
/// policy sheets fanning out of the insurance picture and the fine blanks
/// dropping under the traffic scene.
class OnboardingFlyIn extends StatelessWidget {
  const OnboardingFlyIn({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.from,
    required this.turns,
    required this.child,
    this.scaleFrom = 1,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Offset from;
  final double turns;
  final double scaleFrom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final move = Interval(begin, end, curve: Curves.easeOutBack);
    final fade = Interval(begin, begin + (end - begin) / 2, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = move.transform(animation.value);
        return Opacity(
          opacity: fade.transform(animation.value).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: from * (1 - progress),
            child: Transform.rotate(
              angle: turns * 2 * math.pi * progress,
              child: Transform.scale(
                scale: scaleFrom + (1 - scaleFrom) * progress,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
