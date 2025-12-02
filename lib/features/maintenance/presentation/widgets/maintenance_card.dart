import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/router/app_router.dart';
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
    final scheduleCubit = context.watch<ScheduleCubit>();
    final purchaseCubit = context.watch<PurchaseCubit>();
    final remoteConfigService = context.watch<RemoteConfigService>();
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
                      Text(
                        _translateLabel(category, context),
                        style: textTheme.black16bold.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(description, style: textTheme.black16bold),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.settings, size: 20, color: AppColors.neutreGrey),
                  onPressed: () {
                    context.router.push(
                      SettingsRoute(
                        remoteConfigService: remoteConfigService,
                        scheduleCubit: scheduleCubit,
                        purchaseCubit: purchaseCubit,
                        onBack: () => context.router.pop(),
                      ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${S.of(context).previous}: ${priorExecution ?? "-"}", style: textTheme.black13W400),
                    Text(
                      "${S.of(context).mileage}: ${convert(lastMileage).toStringAsFixed(0)} $unit",
                      style: textTheme.black13W400,
                    ),
                    Text(
                      "${S.of(context).fact}: ${convert(actualMileage).toStringAsFixed(0)} $unit",
                      style: textTheme.black13W400,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "${S.of(context).periodicity} ${convert(intervalKm).toStringAsFixed(0)} $unit",
                      style: textTheme.black13W400,
                    ),
                    Text(
                      intervalTime != null
                          ? "${S.of(context).every} ${intervalTime!.inDays} ${S.of(context).days}"
                          : "${S.of(context).every}${intervalKm ?? 0} ${S.of(context).km}",
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

String _translateLabel(String key, BuildContext context) {
  switch (key) {
    case 'Oil':
      return S.of(context).oil_icon;
    case 'Coolant':
      return S.of(context).coolant_icon;
    case 'Service':
      return S.of(context).service_icon;
    case 'Repair':
      return S.of(context).repair_icon;
    case 'Battery':
      return S.of(context).battery;
    case 'Tuning':
      return S.of(context).tuning;
    case 'Tires':
      return S.of(context).tires_icon;
    case 'Insurance':
      return S.of(context).insurance;
    default:
      return key;
  }
}
