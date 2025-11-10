
import 'dart:math' as math;

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';







class MainStatsCard extends StatelessWidget {
  final int? lastOdometer;
  final double totalCost;
  final double averageFuelConsumption;
  final double monthMileage;

  const MainStatsCard({
    super.key,
    required this.lastOdometer,
    required this.totalCost,
    required this.averageFuelConsumption,
    required this.monthMileage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final costPerKm = monthMileage > 0 ? totalCost / monthMileage : 0.0;

    return Card(
      color: AppColors.energyBlue50, 
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
        child: Column(
          children: [
          
          
            SizedBox(
              height: 102,
              width: double.infinity,
              child: CustomPaint(
                painter: _StatsRingsPainter(
                  totalCostPercent: (totalCost / 20000).clamp(0.0, 1.0),
                  costPerKmPercent: (costPerKm / 17).clamp(0.0, 1.0),
                  fuelPercent: (averageFuelConsumption / 20).clamp(0.0, 1.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context).total_costs, style: textTheme.black20bold),
                      Text(
                        totalCost.toStringAsFixed(0),
                        style: const TextStyle(color: AppColors.blueAccent, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Text("${S.of(context).mileage} ${lastOdometer ?? 0}", style: textTheme.black18W400),
                    ],
                  ),
                ),
              ),
            ),
          
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                       Image.asset(
                      'assets/icons/finance.png',
                      width: 24,
                      height: 24,
                      color: Colors.blueAccent, 
                    ),
                    _StatValue(value: costPerKm.toStringAsFixed(2), label: "UAH/km"),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.local_gas_station, color: Colors.blueAccent, size: 24),
                    _StatValue(
                      value: averageFuelConsumption > 0 ? averageFuelConsumption.toStringAsFixed(1) : "0.0",
                      label: "l/100km",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  final String value;
  final String label;

  const _StatValue({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style:textTheme.blue28W400,
        ),
        Text(label, style: textTheme.hintAnalitText),
      ],
    );
  }
}


class _StatsRingsPainter extends CustomPainter {
  final double totalCostPercent;
  final double costPerKmPercent;
  final double fuelPercent;

  _StatsRingsPainter({required this.totalCostPercent, required this.costPerKmPercent, required this.fuelPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.2);
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

    
    final leftPaintBg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = smallStroke
      ..strokeCap = StrokeCap.round;

    final leftPaintActive = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = smallStroke
      ..strokeCap = StrokeCap.round;

    final leftCenter = Offset(center.dx - radius - 35, center.dy);
    final leftRect = Rect.fromCircle(center: leftCenter, radius: 52);
    canvas.drawArc(leftRect, math.pi / 1.45, math.pi, false, leftPaintBg);
    canvas.drawArc(leftRect, math.pi / 1.45, math.pi * costPerKmPercent, false, leftPaintActive);

  
    final rightCenter = Offset(center.dx + radius + 35, center.dy);
    final rightRect = Rect.fromCircle(center: rightCenter, radius: 52);
    canvas.drawArc(rightRect, -math.pi / 1.45, math.pi, false, leftPaintBg);
    canvas.drawArc(rightRect, -math.pi / 1.45, math.pi * fuelPercent, false, leftPaintActive);
  }

  @override
  bool shouldRepaint(covariant _StatsRingsPainter oldDelegate) {
    return oldDelegate.totalCostPercent != totalCostPercent ||
        oldDelegate.costPerKmPercent != costPerKmPercent ||
        oldDelegate.fuelPercent != fuelPercent;
  }
}
