import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// Overlay for the three lamps of the traffic light in
/// `onboarding_fines.jpg`, where all lamps are drawn lit: the lamps that are
/// "off" get a dark tint, the lit one a coloured glow. One [loop] (0..1)
/// runs Ukrainian order red -> red+yellow -> green -> yellow.
class OnboardingTrafficLight extends StatelessWidget {
  const OnboardingTrafficLight({
    super.key,
    required this.loop,
    required this.pictureSize,
  });

  final Animation<double> loop;
  final Size pictureSize;

  // Measured on the 974x1104 source: lamp column x, lamp centres y and
  // lamp radius, as fractions of the picture.
  static const _lampX = 0.776;
  static const _lampYs = [0.2056, 0.2989, 0.3922];
  static const _lampRadius = 0.0408;
  static const _colors = [
    AppColors.trafficLightRed,
    AppColors.trafficLightYellow,
    AppColors.trafficLightGreen,
  ];

  static List<bool> _litAt(double t) => [
    t < 0.5,
    (t >= 0.4 && t < 0.5) || t >= 0.88,
    t >= 0.5 && t < 0.88,
  ];

  @override
  Widget build(BuildContext context) {
    final radius = pictureSize.height * _lampRadius;
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        final lit = _litAt(loop.value);
        return Stack(
          children: [
            for (var i = 0; i < _lampYs.length; i++)
              Positioned(
                left: pictureSize.width * _lampX - radius,
                top: pictureSize.height * _lampYs[i] - radius,
                width: radius * 2,
                height: radius * 2,
                child: _Lamp(color: _colors[i], isLit: lit[i]),
              ),
          ],
        );
      },
    );
  }
}

class _Lamp extends StatelessWidget {
  const _Lamp({required this.color, required this.isLit});

  final Color color;
  final bool isLit;

  static const _fade = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          opacity: isLit ? 1 : 0,
          duration: _fade,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 10, spreadRadius: 3),
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 22,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: isLit ? 0 : 1,
          duration: _fade,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.trafficLightOff.withValues(alpha: 0.82),
                  AppColors.trafficLightOff.withValues(alpha: 0.78),
                  AppColors.trafficLightOff.withValues(alpha: 0),
                ],
                stops: const [0, 0.7, 1],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
