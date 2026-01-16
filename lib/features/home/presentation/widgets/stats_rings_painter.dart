import 'dart:math' as math;
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

class StatsRingsPainter extends CustomPainter {
  final double totalCostPercent;
  final double costPerKmPercent;
  final double fuelPercent;

   StatsRingsPainter({
    required double totalCostPercent,
    required double costPerKmPercent,
    required double fuelPercent,
  }) : totalCostPercent = _sanitize(totalCostPercent),
       costPerKmPercent = _sanitize(costPerKmPercent),
       fuelPercent = _sanitize(fuelPercent);


  static double _sanitize(double value) {
    if (value.isNaN || !value.isFinite) {
      return 0.0;
    }
    return value.clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double referenceSize = size.width;

    final double mainRadius = referenceSize * 0.28;
    final double smallRadius = referenceSize * 0.2;
    final double sideOffset = referenceSize * 0.35;

    final double mainStroke = referenceSize * 0.027;
    final double smallStroke = referenceSize * 0.02;

    final center = Offset(size.width / 2, size.height * 0.78);

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

   
    final leftCenter = Offset(center.dx - sideOffset, center.dy);
    final leftRect = Rect.fromCircle(center: leftCenter, radius: smallRadius);

  const double leftStartAngle = math.pi * 0.7;
    const double leftSweepAngle = math.pi;

    canvas.drawArc(leftRect, leftStartAngle, leftSweepAngle, false, smallBg);

    canvas.drawArc(leftRect, leftStartAngle, leftSweepAngle * costPerKmPercent, false, smallActive);


   

    final rightCenter = Offset(center.dx + sideOffset, center.dy);
    final rightRect = Rect.fromCircle(center: rightCenter, radius: smallRadius);


    const double rightStartAngle = math.pi * 0.3;


    const double rightSweepAngle = -math.pi;


    canvas.drawArc(rightRect, rightStartAngle, rightSweepAngle, false, smallBg);

    
    canvas.drawArc(rightRect, rightStartAngle, rightSweepAngle * fuelPercent, false, smallActive);

 
    final mainRect = Rect.fromCircle(center: center, radius: mainRadius);

    canvas.drawArc(mainRect, math.pi * 0.9, math.pi * 1.2, false, bgPaint);

    canvas.drawArc(mainRect, math.pi * 0.9, math.pi * 1.2 * totalCostPercent, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant StatsRingsPainter oldDelegate) {
    return oldDelegate.totalCostPercent != totalCostPercent ||
        oldDelegate.costPerKmPercent != costPerKmPercent ||
        oldDelegate.fuelPercent != fuelPercent;
  }
}
