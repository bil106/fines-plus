import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceRecordCard extends StatelessWidget {
  final ServiceRecord record;

  const ServiceRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final settingsCubit = context.watch<SettingsCubit>();
    final currency = settingsCubit.state.currency;
    final symbol = settingsCubit.getCurrencyLabel(context, currency);

    final convertedCost = settingsCubit.convertFromUAH(record.cost);

    return Card(
      color: AppColors.neutreBlanc,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.build, size: 50, color: AppColors.blue700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.serviceName,
                        style: textTheme.historyText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                      AppSpacers.verticalXSmall,
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: AppColors.green),
                          AppSpacers.horizontalSmallMedium,
                          Expanded(
                            child: Text(
                              "${convertedCost.toStringAsFixed(0)} $symbol",
                              style: textTheme.subtitleText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppColors.energyBlue, size: 20),
                    const SizedBox(width: 2),

                    Text(record.date, style: textTheme.subtitleText),

                    const SizedBox(width: 10),
                    Icon(Icons.speed, color: AppColors.energyBlue, size: 20),
                    const SizedBox(width: 4),

                    Builder(
                      builder: (context) {
                        final unitStream = UnitStream(settingsCubit);
                        return StreamBuilder<double>(
                          stream: unitStream.unitValueStream(record.mileage.toDouble()),
                          initialData: unitStream.convert(record.mileage.toDouble()),
                          builder: (context, snapshot) {
                            final value = snapshot.data ?? record.mileage.toDouble();
                            final unit = settingsCubit.state.unit;
                            return Text("${value.toStringAsFixed(0)} $unit", style: textTheme.subtitleText);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
