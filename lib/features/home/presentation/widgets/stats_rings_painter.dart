import 'dart:math' as math;
import 'package:flutter/material.dart';



class StatsRingsPainter extends CustomPainter {
  final double totalCostPercent;
  final double costPerKmPercent;
  final double fuelPercent;
  final Color activeColor;
  final Color bgColor;

  StatsRingsPainter({
    required this.totalCostPercent,
    required this.costPerKmPercent,
    required this.fuelPercent,
    required this.activeColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    final radius = size.width * 0.35;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Общий угол (2/3 круга)
    const totalAngle = math.pi * 4 / 3;
    const startAngle = math.pi * 5 / 6;

    // Рисуем три сегмента кольца, как на скрине — не вложенные, а последовательно расположенные

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Сегмент 1 — totalCost
    final arc1Start = startAngle;
    final arc1Sweep = totalAngle * totalCostPercent;
    canvas.drawArc(rect, arc1Start, totalAngle / 3, false, bgPaint);
    canvas.drawArc(rect, arc1Start, arc1Sweep / 3, false, activePaint);

    // Сегмент 2 — costPerKm
    final arc2Start = startAngle + totalAngle / 3 + 0.1; // немного отступ
    final arc2Sweep = totalAngle * costPerKmPercent;
    canvas.drawArc(rect, arc2Start, totalAngle / 3, false, bgPaint);
    canvas.drawArc(rect, arc2Start, arc2Sweep / 3, false, activePaint);

    // Сегмент 3 — fuel
    final arc3Start = startAngle + 2 * (totalAngle / 3) + 0.2; // отступ
    final arc3Sweep = totalAngle * fuelPercent;
    canvas.drawArc(rect, arc3Start, totalAngle / 3, false, bgPaint);
    canvas.drawArc(rect, arc3Start, arc3Sweep / 3, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant StatsRingsPainter oldDelegate) {
    return totalCostPercent != oldDelegate.totalCostPercent ||
        costPerKmPercent != oldDelegate.costPerKmPercent ||
        fuelPercent != oldDelegate.fuelPercent ||
        activeColor != oldDelegate.activeColor ||
        bgColor != oldDelegate.bgColor;
  }
}
