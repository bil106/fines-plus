import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceCard extends StatelessWidget {
  final String description;
  final String category;
  final double progress;
  final String? priorExecution;
  final int? lastMileage;
  final int? actualMileage;
  final Duration? intervalTime;
  final int? intervalKm;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;
  final bool? isWarning;

  final IconData? icon;
  final Widget? iconWidget;

  const MaintenanceCard({
    super.key,
    required this.description,
    required this.category,
    required this.progress,
    this.priorExecution,
    this.lastMileage,
    this.actualMileage,
    this.intervalKm,
    this.intervalTime,
    this.onPressed,
    this.onDelete,
    this.isWarning,
    this.icon,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final settingsCubit = context.watch<SettingsCubit>();
    final unit = settingsCubit.state.unit;
    final labelStyle = textTheme.bodySmall?.copyWith(
      fontSize: 12.5,
      color: AppColors.textSecondary,
    );

    double convert(int? value) {
      if (value == null) return 0;
      return unit == 'mil' ? value * 0.621371 : value.toDouble();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        borderRadius: AppBorders.radius16,
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    context.router.push(
                      SettingsRoute(onBack: () => context.router.pop()),
                    );
                  },
                ),
              ],
            ),

            AppSpacers.verticalSmall,

            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: context.brandTheme.statusWarning
                          .withValues(alpha: 0.12),
                      child:
                          iconWidget ??
                          Icon(
                            icon ?? Icons.build,
                            color: context.brandTheme.statusWarning,
                            size: 30,
                          ),
                    ),
                    if (isWarning != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: isWarning!
                              ? context.brandTheme.statusDanger
                              : context.brandTheme.statusSuccess,
                          child: Icon(
                            isWarning! ? Icons.error : Icons.check,
                            color: AppColors.neutreBlanc,
                            size: 14,
                          ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
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
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${S.of(context).mileage}:", style: labelStyle),
                          const SizedBox(height: 2),
                          Text(
                            "${convert(lastMileage).toStringAsFixed(0)} $unit",
                            style: labelStyle?.copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${S.of(context).fact}:", style: labelStyle),
                          const SizedBox(height: 2),
                          Text(
                            "${convert(actualMileage).toStringAsFixed(0)} $unit",
                            style: labelStyle?.copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.of(context).periodicity, style: labelStyle),
                          const SizedBox(height: 2),
                          Text(
                            "${convert(intervalKm).toStringAsFixed(0)} $unit",
                            style: labelStyle?.copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${S.of(context).every}:", style: labelStyle),
                          const SizedBox(height: 2),
                          Text(
                            intervalTime != null
                                ? "${intervalTime!.inDays} ${S.of(context).days}"
                                : "-",
                            style: labelStyle?.copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

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
