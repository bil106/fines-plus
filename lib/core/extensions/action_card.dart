import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/schedule/presentation/widgets/action_detail_sheet.dart';
import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double progress;
  final String priorExecution;
  final String periodicity;
  final bool isWarning;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.priorExecution,
    required this.periodicity,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: textTheme.black16bold)),
                const Icon(Icons.settings, size: 20, color: AppColors.neutreGrey),
              ],
            ),
            AppSpacers.verticalMedium,

            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.energyBlue50,
                      child: Icon(icon, color: AppColors.amber, size: 30),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: isWarning ? AppColors.red : AppColors.green,
                        child: Icon(isWarning ? Icons.error : Icons.check, color: AppColors.neutreBlanc, size: 14),
                      ),
                    ),
                  ],
                ),
                AppSpacers.horizontalMediumLarge,

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).resource),
                      AppSpacers.verticalXSmall,
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 18,
                            borderRadius: BorderRadius.circular(8),
                            backgroundColor: AppColors.grey300,
                            valueColor: AlwaysStoppedAnimation<Color>(isWarning ? AppColors.red : AppColors.lightGreen),
                          ),
                          Text("${(progress * 100).toStringAsFixed(0)}%", style: textTheme.white14W400),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacers.verticalSmall,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${S.of(context).to_be_performed} \n$priorExecution", style: textTheme.black13W400),
                Container(width: 1, height: 32, color: AppColors.grey300),
                Text("${S.of(context).periodicity}\n$periodicity", style: textTheme.black13W400),
              ],
            ),

            Center(
              child: TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (_) => Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: ActionDetailSheet(description: title),
                    ),
                  );
                },
                child: Text(S.of(context).configure_action),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
