import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
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
    final labelStyle = textTheme.bodySmall?.copyWith(
      fontSize: 12.5,
      color: AppColors.textSecondary,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radius16,
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).insurance,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),

            AppSpacers.verticalMedium,

            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.brandTheme.statusWarning.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons.shield,
                    color: context.brandTheme.statusWarning,
                    size: 30,
                  ),
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
                        backgroundColor: context.brandTheme.surfaceBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8
                              ? context.brandTheme.statusDanger
                              : context.brandTheme.statusSuccess,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.neutreBlanc,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpacers.verticalMedium,

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${S.of(context).previous}:", style: labelStyle),
                      const SizedBox(height: 2),
                      Text(
                        priorExecution ?? "-",
                        style: labelStyle?.copyWith(color: AppColors.ink),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Text(
                  intervalTime != null
                      ? "${S.of(context).every} ${intervalTime!.inDays} ${S.of(context).days}"
                      : "-",
                  style: labelStyle?.copyWith(color: AppColors.ink),
                ),
              ],
            ),

            AppSpacers.verticalSmallMedium,

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onPressed,
                    child: Text(
                      S.of(context).configure_action,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: context.brandTheme.statusDanger,
                  ),
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
