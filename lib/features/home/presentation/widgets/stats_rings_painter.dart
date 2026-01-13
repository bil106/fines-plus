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
  final double referenceSize = size.width;


  final double mainRadius = referenceSize * 0.28;
  final double smallRadius = referenceSize * 0.2;
  final double sideOffset = referenceSize * 0.35; 

  final double mainStroke = referenceSize * 0.027; 
  final double smallStroke = referenceSize * 0.02; 


  final center = Offset(size.width / 2, size.height * 0.75);

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
  
  canvas.drawArc(leftRect, math.pi * 0.7, math.pi, false, smallBg);
 
  canvas.drawArc(leftRect, math.pi * 1.7, -math.pi * costPerKmPercent.clamp(0.0, 1.0), false, smallActive);

 
  final rightCenter = Offset(center.dx + sideOffset, center.dy); 
  final rightRect = Rect.fromCircle(center: rightCenter, radius: smallRadius);

  canvas.drawArc(rightRect, -math.pi * 0.7, math.pi, false, smallBg);

  canvas.drawArc(rightRect, math.pi * 1.5, math.pi * fuelPercent.clamp(0.0, 1.0), false, smallActive);

 
  final mainRect = Rect.fromCircle(center: center, radius: mainRadius);
  
  canvas.drawArc(mainRect, math.pi * 0.9, math.pi * 1.2, false, bgPaint);
  canvas.drawArc(mainRect, math.pi * 0.9, math.pi * 1.2 * totalCostPercent.clamp(0.0, 1.0), false, activePaint);
}

 @override
  bool shouldRepaint(covariant StatsRingsPainter oldDelegate) {
    
    return oldDelegate.totalCostPercent != totalCostPercent ||
        oldDelegate.costPerKmPercent != costPerKmPercent ||
        oldDelegate.fuelPercent != fuelPercent;
  }
}