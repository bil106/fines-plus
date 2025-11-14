import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/widgets/stat_value.dart';
import 'package:fines_plus/features/home/presentation/widgets/stats_rings_painter.dart';
import 'package:flutter/material.dart';

class MainStatsCard extends StatelessWidget {
  final MainStats stats;

  const MainStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppColors.energyBlue50,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
        child: Column(
          children: [
            SizedBox(
              height: 102,
              width: double.infinity,
              child: CustomPaint(
                painter: StatsRingsPainter(
                  totalCostPercent: stats.totalCostPercent,
                  costPerKmPercent: stats.costPerKmPercent,
                  fuelPercent: stats.fuelPercent,
                ),
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(S.of(context).total_costs, style: textTheme.black20bold),
                        Text(
                          stats.totalCost.toStringAsFixed(0),
                          style: const TextStyle(
                            color: AppColors.blueAccent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${S.of(context).mileage} ${stats.lastOdometer}${S.of(context).km}",
                          style: textTheme.black18W400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset('assets/icons/coin_stack.png', width: 24, height: 24, color: Colors.blueAccent),
                    const SizedBox(height: 4),
                    StatValue(value: stats.costPerKm.toStringAsFixed(1), label: "UAH/km"),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.local_gas_station, color: Colors.blueAccent, size: 24),
                    const SizedBox(height: 4),
                    StatValue(
                      value: stats.averageFuelConsumption > 0 ? stats.averageFuelConsumption.toStringAsFixed(1) : "0.0",
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
