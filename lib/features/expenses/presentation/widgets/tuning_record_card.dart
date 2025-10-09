import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/icons/tuning.jpg',
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 8), 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Text(
                    record.tuningName,
                    style: textTheme.historyText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          color: AppColors.green, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${record.cost.toStringAsFixed(0)} ${S.of(context).grn}",
                          style: textTheme.subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                
                  Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          color: AppColors.energyBlue, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          record.date,
                          style: textTheme.subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.speed,
                          color: AppColors.energyBlue, size: 18),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "${record.mileage} ${S.of(context).km}",
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
      ),
    );
  }
}


