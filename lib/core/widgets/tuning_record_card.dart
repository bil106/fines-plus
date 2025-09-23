import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TuningRecordCard extends StatelessWidget {
  final TuningRecord record;
  const TuningRecordCard({super.key, required this.record});

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
            Image.asset('assets/icons/tuning.jpg', height: 50, width: 50), 

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSpacers.horizontalSmallMedium,
                    Text(record.tuningName, style: textTheme.historyText),
                  ],
                ),
                AppSpacers.verticalXSmall,
                Row(
                  children: [
                    Icon(Icons.attach_money, color: AppColors.green),
                    AppSpacers.horizontalSmallMedium,
                    Text("${record.cost.toStringAsFixed(0)} ${S.of(context).grn}", style: textTheme.subtitleText),
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

