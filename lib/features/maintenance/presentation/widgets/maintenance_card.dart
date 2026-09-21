import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
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

    double convert(int? value) {
      if (value == null) return 0;
      return unit == 'mil' ? value * 0.621371 : value.toDouble();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(description, style: textTheme.black16bold),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.settings, size: 20, color: AppColors.neutreGrey),
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
              Text("${S.of(context).previous}:", style: textTheme.black13W400),
              const SizedBox(height: 2),
              Text(priorExecution ?? "-", style: textTheme.black13W400),
            ],
          ),
          const SizedBox(height: 4),

        
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${S.of(context).mileage}:", style: textTheme.black13W400),
              const SizedBox(height: 2),
              Text("${convert(lastMileage).toStringAsFixed(0)} $unit", style: textTheme.black13W400),
            ],
          ),
          const SizedBox(height: 4),

     
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${S.of(context).fact}:", style: textTheme.black13W400),
              const SizedBox(height: 2),
              Text("${convert(actualMileage).toStringAsFixed(0)} $unit", style: textTheme.black13W400),
            ],
          ),
        ],
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).periodicity, style: textTheme.black13W400),
              const SizedBox(height: 2),
              Text("${convert(intervalKm).toStringAsFixed(0)} $unit", style: textTheme.black13W400),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${S.of(context).every}:", style: textTheme.black13W400),
              const SizedBox(height: 2),
              Text(
                intervalTime != null
                    ? "${intervalTime!.inDays} ${S.of(context).days}"
                    : "-",
                style: textTheme.black13W400,
              ),
            ],
          ),
        ],
      ),
    ),
  ],
)
,


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
