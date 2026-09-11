import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/date_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarWashRecordCard extends StatelessWidget {
  final CarWashRecord record;

  const CarWashRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppColors.neutreBlanc,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only( left: 10),
                  child: Icon(Icons.local_car_wash, color: AppColors.energyBlue, size: 50),
                ),
                const SizedBox(width: 50),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).car_wash, style: textTheme.historyText, overflow: TextOverflow.ellipsis),

                      Row(
                        children: [
                          Icon(Icons.attach_money, color: AppColors.green, ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final settingsCubit = context.watch<SettingsCubit>();
                              final targetCurrency = settingsCubit.state.currency;
                              final amountBase = record.amount;
                              final displayCurrency = settingsCubit.getCurrencyLabel(context, targetCurrency);
                              final convertedCost = settingsCubit.currencyService.convert(
                                amountBase,
                                targetCurrency,
                                fromCurrency: 'UAH',
                              );
                              return Flexible(
                                child: Text(
                                  "${convertedCost.toStringAsFixed(0)} $displayCurrency",
                                  style: textTheme.subtitleText,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppColors.energyBlue, size: 20),
                    const SizedBox(width: 2),

                    Text(DateFormatter.formatDate(record.date), style: textTheme.subtitleText),

                    const SizedBox(width: 10),
                    Icon(Icons.speed, color: AppColors.energyBlue, size: 20),
                    const SizedBox(width: 4),
                    Builder(
                      builder: (context) {
                        final settingsCubit = context.watch<SettingsCubit>();
                        final unitStream = UnitStream(settingsCubit);

                        return StreamBuilder<double>(
                          stream: unitStream.unitValueStream(record.mileage.toDouble()),
                          initialData: unitStream.convert(record.mileage.toDouble()),
                          builder: (context, snapshot) {
                            final value = snapshot.data ?? record.mileage.toDouble();
                            final unit = settingsCubit.state.unit;
                            return Text(
                              "${value.toStringAsFixed(0)} $unit",
                              style: textTheme.subtitleText,
                              overflow: TextOverflow.ellipsis,
                            );
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
