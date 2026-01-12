import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/core/helpers/stat_column.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/widgets/stats_rings_painter.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainStatsCard extends StatelessWidget {
  final MainStats stats;

  const MainStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final currencyService = context.read<CurrencyService?>();
    if (currencyService == null) {
      return const SizedBox.shrink(); 
    }

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
        child: Column(
          children: [
          AspectRatio(
              aspectRatio: 3.2,
              child: CustomPaint(
                painter: StatsRingsPainter(
                  totalCostPercent: stats.totalCostPercent,
                  costPerKmPercent: stats.costPerKmPercent,
                  fuelPercent: stats.fuelPercent,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: LayoutBuilder(
                    builder: (context, constraints) {

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(S.of(context).total_costs, style: textTheme.black20bold),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${totalCostConverted.toStringAsFixed(0)} $selectedCurrency',
                                style: TextStyle(
                                  color: AppColors.blueAccent,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Flexible(
                            child: StreamBuilder<double>(
                              stream: unitStream.unitValueStream(stats.lastOdometer.toDouble()),
                              initialData: unitStream.convert(stats.lastOdometer.toDouble()),
                              builder: (context, snapshot) {
                                final mileageValue = snapshot.data ?? stats.lastOdometer.toDouble();
                                final unit = settingsCubit.state.unit == 'mil' ? 'mil' : S.of(context).km;

                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${S.of(context).mileage} ${mileageValue.toStringAsFixed(0)} $unit",
                                    style: textTheme.black18W400,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatColumn(
                  icon: Image.asset(
                    'assets/icons/coin_stack.png',
                    width: 24.w,
                    height: 24.w,
                    color: AppColors.blueAccent,
                  ),
                  value: costPerKmConverted.toStringAsFixed(1),
                  label: "$selectedCurrency/${settingsCubit.state.unit}",
                ),
                StatColumn(
                  icon: Icon(Icons.local_gas_station, color: AppColors.blueAccent, size: 24.w),
                  valueStream: unitStream.fuelConsumptionStream(stats.averageFuelConsumption),
                  fallbackValue: stats.averageFuelConsumption,
                  labelBuilder: (value) {
                    final fuelUnit = settingsCubit.state.fuelConsumptionUnit;
                    return fuelUnit == 'l/100km' ? "l/100${S.of(context).km}" : "mpg";
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
