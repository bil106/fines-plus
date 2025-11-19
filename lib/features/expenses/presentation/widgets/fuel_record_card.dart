import 'package:core_utils/formatters/date_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FuelRecordCard extends StatelessWidget {
  final FuelRecord record;
  const FuelRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsCubit = context.watch<SettingsCubit>();
    final unitStream = UnitStream(settingsCubit);


    final currencyService = context.read<CurrencyService>();
    final targetCurrency = settingsCubit.state.currency;

 
    final convertedCost = currencyService.convert(record.cost, targetCurrency, fromCurrency: 'UAH');
    final displayCurrency = settingsCubit.getCurrencyLabel(context, targetCurrency);

    return Card(
      color: AppColors.neutreBlanc,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.local_gas_station, color: AppColors.redAccent, size: 50),
            AppSpacers.horizontalSmallMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${record.fuelType} / ${record.volume.toInt()}L", style: textTheme.historyText),
                  AppSpacers.verticalXSmall,

              
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: AppColors.green),
                      AppSpacers.horizontalSmallMedium,
                      Text("${convertedCost.toStringAsFixed(0)} $displayCurrency", style: textTheme.subtitleText),
                    ],
                  ),

                  AppSpacers.verticalXSmall,

              
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: AppColors.energyBlue),
                      AppSpacers.horizontalSmallMedium,
                      Text(DateFormatter.formatDate(record.date), style: textTheme.subtitleText),
                      AppSpacers.horizontalXLarge,
                      Icon(Icons.speed, color: AppColors.energyBlue),
                      AppSpacers.horizontalSmallMedium,

                     
                      StreamBuilder<double>(
                        stream: unitStream.unitValueStream(record.mileage.toDouble()),
                        initialData: unitStream.convert(record.mileage.toDouble()),
                        builder: (context, snapshot) {
                          final mileageValue = snapshot.data ?? record.mileage.toDouble();
                          final unit = settingsCubit.state.unit;
                          return Text("${mileageValue.toStringAsFixed(0)} $unit", style: textTheme.subtitleText);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
