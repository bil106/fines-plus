import 'dart:math' as math;

import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// A highlight sweeping round the metal rim of the maintenance badge
/// (`maintenance_bg.png`). Rim geometry is given as fractions of the painted
/// square so it stays glued to the picture at any size.
class OnboardingGlarePainter extends CustomPainter {
  OnboardingGlarePainter({required this.rotation}) : super(repaint: rotation);

  final Animation<double> rotation;

  // Measured on maintenance_bg.png (225x225): rim centre, mid radius and
  // thickness of the silver ring.
  static const _centerX = 0.498;
  static const _centerY = 0.502;
  static const _radius = 0.42;
  static const _thickness = 0.058;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final center = Offset(size.width * _centerX, size.height * _centerY);
    final rect = Rect.fromCircle(center: center, radius: side * _radius);
    final glare = AppColors.neutreBlanc;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation.value * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * _thickness
      ..blendMode = BlendMode.screen
      ..shader = SweepGradient(
        colors: [
          glare.withValues(alpha: 0),
          glare.withValues(alpha: 0),
          glare.withValues(alpha: 0.55),
          glare,
          glare.withValues(alpha: 0.55),
          glare.withValues(alpha: 0),
        ],
        stops: const [0, 0.62, 0.72, 0.76, 0.8, 0.9],
      ).createShader(rect);
    canvas.drawCircle(center, rect.width / 2, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(OnboardingGlarePainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
