import 'dart:math' as math;
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

class StatsRingsPainter extends CustomPainter {
  final double totalCostPercent;
  final double costPerKmPercent;
  final double fuelPercent;

  const StatsRingsPainter({required this.totalCostPercent, required this.costPerKmPercent, required this.fuelPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.15);
    const mainStroke = 10.0;
    const smallStroke = 6.0;

    final bgColor = AppColors.energyBlue25;
    final activeColor = AppColors.blue700;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = mainStroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = mainStroke
      ..strokeCap = StrokeCap.round;

    final radius = size.width * 0.3;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, math.pi * 5 / 6, math.pi * 4 / 3, false, bgPaint);
    canvas.drawArc(rect, math.pi * 5 / 6, math.pi * 4 / 3 * totalCostPercent, false, activePaint);

    final smallBg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = smallStroke
      ..strokeCap = StrokeCap.round;

    final smallActive = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = smallStroke
      ..strokeCap = StrokeCap.round;

    final leftCenter = Offset(center.dx - radius - 35, center.dy);
    final leftRect = Rect.fromCircle(center: leftCenter, radius: 52);
    canvas.drawArc(leftRect, math.pi / 1.45, math.pi, false, smallBg);
    canvas.drawArc(leftRect, math.pi / 1.45, math.pi * costPerKmPercent, false, smallActive);

    final rightCenter = Offset(center.dx + radius + 35, center.dy);
    final rightRect = Rect.fromCircle(center: rightCenter, radius: 52);
    canvas.drawArc(rightRect, -math.pi / 1.45, math.pi, false, smallBg);
    canvas.drawArc(rightRect, -math.pi / 1.45, math.pi * fuelPercent, false, smallActive);
  }

  @override
  bool shouldRepaint(covariant StatsRingsPainter old) =>
      old.totalCostPercent != totalCostPercent ||
      old.costPerKmPercent != costPerKmPercent ||
      old.fuelPercent != fuelPercent;
}
