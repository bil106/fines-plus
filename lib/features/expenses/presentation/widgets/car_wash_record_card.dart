import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:flutter/material.dart';

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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSpacers.horizontalSmallMedium,
                    Text(S.of(context).car_wash, style: textTheme.historyText),
                  ],
                ),
                AppSpacers.verticalXSmall,
                Row(
                  children: [
                    Icon(Icons.attach_money, color: AppColors.green),
                    AppSpacers.horizontalSmallMedium,
                    Text("${record.cost} ${S.of(context).grn}", style: textTheme.subtitleText),
                  ],
                ),
                AppSpacers.verticalXSmall,
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppColors.energyBlue),
                    AppSpacers.horizontalSmallMedium,
                    Text(record.date, style: textTheme.subtitleText),
                    AppSpacers.horizontalXLarge,
                    Icon(Icons.speed, color: AppColors.energyBlue),
                    AppSpacers.horizontalSmallMedium,
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
