import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/date_formatter.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.local_car_wash, color: AppColors.energyBlue, size: 50),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(S.of(context).car_wash, style: textTheme.historyText)]),
                const SizedBox(height: 4),
             Row(
                  children: [
                    Icon(Icons.attach_money, color: AppColors.green),
                    const SizedBox(width: 8),

                    Builder(
                      builder: (context) {
                        final settingsCubit = context.watch<SettingsCubit>();
                        final currency = settingsCubit.state.currency;
                        final currencyLabel = settingsCubit.getCurrencyLabel(context, currency);

                        return Text(
                          "${record.amount.toStringAsFixed(0)} $currencyLabel",
                          style: textTheme.subtitleText,
                        );
                      },
                    ),
                  ],
                ),


                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppColors.energyBlue),
                    const SizedBox(width: 8),
                    Text(DateFormatter.formatDate(record.date), style: textTheme.subtitleText),
                    const SizedBox(width: 24),
                    Icon(Icons.speed, color: AppColors.energyBlue),
                    const SizedBox(width: 8),
                    Text("${record.mileage} ${S.of(context).km}", style: textTheme.subtitleText),
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
