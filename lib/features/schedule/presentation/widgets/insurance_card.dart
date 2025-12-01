import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.watch<SettingsCubit>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).insurance, style: textTheme.black16bold.copyWith(fontWeight: FontWeight.bold)),

            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.energyBlue50,
                      child: Icon(Icons.shield, color: AppColors.orange, size: 30),
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

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("${S.of(context).previous}: ${priorExecution ?? "-"}", style: textTheme.black13W400)],
                ),
                Column(
                  children: [
                    Text(
                      "${S.of(context).every} ${intervalTime!.inDays} ${S.of(context).days}",
                      style: textTheme.black13W400,
                    ),
                  ],
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
