import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InsuranceCard extends StatelessWidget {
  final double progress;
  final String? priorExecution;
  final Duration? intervalTime;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;

  const InsuranceCard({
    super.key,
    required this.progress,
    this.priorExecution,
    this.intervalTime,
    this.onPressed,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).insurance, style: textTheme.bodyStrong.copyWith(fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.energyBlue50,
                  child: Icon(Icons.shield, color: AppColors.orange, size: 30),
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
                      Text("${(progress * 100).toStringAsFixed(0)}%", style: textTheme.whiteCaption),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${S.of(context).previous}:", style: textTheme.caption),
                      const SizedBox(height: 2),
                      Text(priorExecution ?? "-", style: textTheme.caption),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Text(
                  intervalTime != null ? "${S.of(context).every} ${intervalTime!.inDays} ${S.of(context).days}" : "-",
                  style: textTheme.caption,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onPressed,
                    child: Text(S.of(context).configure_action, overflow: TextOverflow.ellipsis),
                  ),
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
