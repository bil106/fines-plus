import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MaintenanceCard extends StatelessWidget {
  final String title;
  final double progress;
  final String? priorExecution;
  final int? lastMileage;
  final int? actualMileage;
  final int? intervalKm;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;
  final bool? isWarning;

  final IconData? icon;
  final Widget? iconWidget;

  const MaintenanceCard({
    super.key,
    required this.title,
    required this.progress,
    this.priorExecution,
    this.lastMileage,
    this.actualMileage,
    this.intervalKm,
    this.onPressed,
    this.onDelete,
    this.isWarning,
    this.icon,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16,vertical: 8 ),
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
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.energyBlue50,
                      child:
                          iconWidget ??
                          Icon(icon ?? Icons.build, color: icon != null ? AppColors.amber : AppColors.orange, size: 30),
                    ),
                    if (isWarning != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: isWarning! ? AppColors.red : AppColors.green,
                          child: Icon(isWarning! ? Icons.error : Icons.check, color: AppColors.neutreBlanc, size: 14),
                        ),
                      ),
                  ],
                ),
                AppSpacers.horizontalMedium,
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 22,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: AppColors.grey300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8 ? AppColors.red : AppColors.lightGreen,
                        ),
                      ),
                      Text("${(progress * 100).toStringAsFixed(0)}%", style: textTheme.white14W400),
                    ],
                  ),
                ),
              ],
            ),

            

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${S.of(context).previous}: ${priorExecution ?? "-"}", style: textTheme.black13W400),
                    Text("${S.of(context).mileage}: ${lastMileage?.toString() ?? "-"}", style: textTheme.black13W400),
                    Text("${S.of(context).fact}: ${actualMileage?.toString() ?? "-"}", style: textTheme.black13W400),
                  ],
                ),
                Text(
                  "${S.of(context).periodicity} ${intervalKm?.toString() ?? "-"} ${S.of(context).km}",
                  style: textTheme.black13W400,
                ),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 98.0, right: 30),
                  child: TextButton(onPressed: onPressed, child: Text(S.of(context).configure_action)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
