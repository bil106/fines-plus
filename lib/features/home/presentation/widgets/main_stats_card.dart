import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/widgets/stat_value.dart';
import 'package:fines_plus/features/home/presentation/widgets/stats_rings_painter.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainStatsCard extends StatelessWidget {
  final MainStats stats;

  const MainStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final currencyService = context.read<CurrencyService>();
    final settingsCubit = context.watch<SettingsCubit>();
    final selectedCurrency = settingsCubit.state.currency;

    final totalCostConverted = currencyService.convert(
      stats.totalCost,
      selectedCurrency,
      fromCurrency: S.of(context).grn,
    );

    final costPerKmConverted = currencyService.convert(
      stats.costPerKm,
      selectedCurrency,
      fromCurrency: S.of(context).grn,
    );

    final unitStream = UnitStream(settingsCubit);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
        child: Column(
          children: [
            SizedBox(
              height: 105,
              width: double.infinity,
              child: CustomPaint(
                painter: StatsRingsPainter(
                  totalCostPercent: stats.totalCostPercent,
                  costPerKmPercent: stats.costPerKmPercent,
                  fuelPercent: stats.fuelPercent,
                ),
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, 30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).total_costs,
                              style: textTheme.subheading,
                            ),
                            Text(
                              '${totalCostConverted.toStringAsFixed(0)} $selectedCurrency',
                              style: const TextStyle(
                                color: AppColors.blueAccent,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Builder(
                              builder: (context) {
                                final mileageValue = unitStream.convert(
                                  stats.lastOdometer.toDouble(),
                                );
                                final unit = settingsCubit.state.unit == 'mil'
                                    ? 'mil'
                                    : S.of(context).km;

                                return Text(
                                  "${mileageValue.toStringAsFixed(0)} $unit",
                                  style: textTheme.subtitleText,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/coin_stack.png',
                        width: 24,
                        height: 24,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 4),
                      StatValue(
                        value: costPerKmConverted.toStringAsFixed(1),
                        label: "$selectedCurrency/${settingsCubit.state.unit}",
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_gas_station,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final value = unitStream.convertFuel(
                            stats.averageFuelConsumption,
                          );
                          final fuelUnit =
                              settingsCubit.state.fuelConsumptionUnit;

                          final unitLabel = fuelUnit == 'l/100km'
                              ? "l/100${S.of(context).km}"
                              : "mpg";

                          return StatValue(
                            value: value.toStringAsFixed(1),
                            label: unitLabel,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
