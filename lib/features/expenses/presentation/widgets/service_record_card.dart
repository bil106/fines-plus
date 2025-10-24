import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:flutter/material.dart';

class ServiceRecordCard extends StatelessWidget {
  final ServiceRecord record;
  const ServiceRecordCard({super.key, required this.record});

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
            Icon(Icons.build, size: 50, color: AppColors.blue700),
            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.serviceName, style: textTheme.historyText),
                  AppSpacers.verticalXSmall,
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: AppColors.green),
                      AppSpacers.horizontalSmallMedium,
                      Text("${record.cost.toStringAsFixed(0)} ₴", style: textTheme.subtitleText),
                    ],
                  ),
                  AppSpacers.verticalXSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month, color: AppColors.energyBlue),
                            AppSpacers.horizontalSmallMedium,
                            Flexible(
                              child: Text(record.date, style: textTheme.subtitleText, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),

                   
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.speed, color: AppColors.energyBlue),
                            AppSpacers.horizontalSmallMedium,
                            Flexible(
                              child: Text(
                                "${record.mileage} ${S.of(context).km}",
                                style: textTheme.subtitleText,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
