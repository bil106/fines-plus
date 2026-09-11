import 'dart:math' as math;
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

class StatsRingsPainter extends CustomPainter {
  final double totalCostPercent;
  final double costPerKmPercent;
  final double fuelPercent;

  StatsRingsPainter({required double totalCostPercent, required double costPerKmPercent, required double fuelPercent})
    : totalCostPercent = _sanitize(totalCostPercent),
      costPerKmPercent = _sanitize(costPerKmPercent),
      fuelPercent = _sanitize(fuelPercent);

  static double _sanitize(double value) {
    if (!value.isFinite || value.isNaN) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final referenceSize = math.min(size.width, size.height);
    if (referenceSize <= 0) return;

    // --- Geometry (SAFE LIMITS) ---
    final mainRadius = referenceSize * 0.88;
    final smallRadius = referenceSize * 0.60;

    final mainStroke = math.min(referenceSize * 0.067, mainRadius * 0.45);
    final smallStroke = math.min(referenceSize * 0.060, smallRadius * 0.45);

    if (mainRadius <= mainStroke || smallRadius <= smallStroke) return;

    final centerX = size.width / 2;

    final mainCenter = Offset(centerX, size.height * 0.85);
    final sideCenterY = size.height * 0.82;
    final sideOffset = referenceSize * 1.1;

    // --- Paints ---
    final bgPaint = Paint()
      ..color = AppColors.energyBlue25
      ..style = PaintingStyle.stroke
      ..strokeWidth = mainStroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = AppColors.blue700
      ..style = PaintingStyle.stroke
      ..strokeWidth = mainStroke
      ..strokeCap = StrokeCap.round;

    final smallBg = Paint()
      ..color = AppColors.energyBlue25
      ..style = PaintingStyle.stroke
      ..strokeWidth = smallStroke
      ..strokeCap = StrokeCap.round;

    final smallActive = Paint()
      ..color = AppColors.blue700
      ..style = PaintingStyle.stroke
      ..strokeWidth = smallStroke
      ..strokeCap = StrokeCap.round;

    // --- Rects ---
    final mainRect = Rect.fromCircle(center: mainCenter, radius: mainRadius);
    final leftRect = Rect.fromCircle(center: Offset(centerX - sideOffset, sideCenterY), radius: smallRadius);
    final rightRect = Rect.fromCircle(center: Offset(centerX + sideOffset, sideCenterY), radius: smallRadius);

    _drawRing(
      canvas,
      size,
      rect: leftRect,
      start: math.pi * 0.7,
      sweep: math.pi,
      percent: costPerKmPercent,
      bg: smallBg,
      active: smallActive,
    );

    _drawRing(
      canvas,
      size,
      rect: rightRect,
      start: math.pi * 0.3,
      sweep: -math.pi,
      percent: fuelPercent,
      bg: smallBg,
      active: smallActive,
    );

    _drawRing(
      canvas,
      size,
      rect: mainRect,
      start: math.pi * 0.9,
      sweep: math.pi * 1.2,
      percent: totalCostPercent,
      bg: bgPaint,
      active: activePaint,
    );
  }

  void _drawRing(
    Canvas canvas,
    Size size, {
    required Rect rect,
    required double start,
    required double sweep,
    required double percent,
    required Paint bg,
    required Paint active,
  }) {
    if (!_rectFits(size, rect)) return;
    if (sweep.abs() < 0.001) return;

    canvas.drawArc(rect, start, sweep, false, bg);

    final activeSweep = sweep * percent;
    if (activeSweep.abs() < 0.001) return;

    canvas.drawArc(rect, start, activeSweep, false, active);
  }

  bool _rectFits(Size size, Rect rect) {
    return rect.left.isFinite && rect.top.isFinite && rect.right.isFinite && rect.bottom.isFinite;
  }

  @override
  bool shouldRepaint(covariant StatsRingsPainter oldDelegate) {
    return oldDelegate.totalCostPercent != totalCostPercent ||
        oldDelegate.costPerKmPercent != costPerKmPercent ||
        oldDelegate.fuelPercent != fuelPercent;
  }
}
