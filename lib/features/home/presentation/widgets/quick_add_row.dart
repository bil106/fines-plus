import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/widget/app_bottom_sheet.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/other_expense_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_sheet.dart';
import 'package:fines_plus/features/home/presentation/widgets/other_expense_sheet.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/tuning_screen.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The dashboard's "quick add" row: the three most common expense actions
/// (Fuel/Service/Insurance) plus a "More" button for everything else -
/// deliberately not all maintenance categories at once, and deliberately
/// no "Add fine" here since fines arrive from the automated check, not a
/// manual entry.
///
/// Replaces the old 4-tile MainExpenseTiles row (Service/CarWash/Fuel/
/// Insurance): same underlying navigation for the three that stayed
/// top-level, Car wash moved into the "More" sheet alongside the rest.
class QuickAddRow extends StatelessWidget {
  const QuickAddRow({super.key});

  @override
  Widget build(BuildContext context) {
    final carId = context.read<CarCubit>().state.carId;

    return Row(
      children: [
        Expanded(
          child: _QuickAddButton(
            icon: Icons.local_gas_station,
            iconColor: AppColors.catFuel,
            label: S.of(context).fuel,
            onTap: () async {
              final fuelKey = GlobalKey<FuelUpScreenState>();
              await AppBottomSheet.show<FuelRecord>(
                context,
                title: S.of(context).fuel,
                contentBuilder: (_) =>
                    FuelUpScreen(key: fuelKey, embedded: true),
                saveLabel: S.of(context).save,
                onSave: () => fuelKey.currentState?.save(),
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _QuickAddButton(
            icon: Icons.build,
            iconColor: AppColors.catService,
            label: S.of(context).maintenance,
            onTap: () async {
              final serviceKey = GlobalKey<ServiceScreenState>();
              final totalUah = ValueNotifier<double>(0);
              // ServiceScreen self-saves via MaintenanceCubit when embedded
              // (see its `embedded` doc comment) - no need to await/save a
              // popped list here, unlike the full-screen route.
              try {
                await AppBottomSheet.show<List<ServiceRecord>>(
                  context,
                  title: S.of(context).maintenance,
                  contentBuilder: (_) => ServiceScreen(
                    key: serviceKey,
                    embedded: true,
                    onTotalChanged: (value) => totalUah.value = value,
                  ),
                  footerBuilder: (_) => ValueListenableBuilder<double>(
                    valueListenable: totalUah,
                    builder: (_, total, _) => ServiceTotal(totalUah: total),
                  ),
                  saveLabel: S.of(context).save,
                  onSave: () => serviceKey.currentState?.save(),
                );
              } finally {
                totalUah.dispose();
              }
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _QuickAddButton(
            icon: Icons.gpp_good,
            iconColor: AppColors.catInsurance,
            label: S.of(context).insurance,
            onTap: () async {
              if (carId.isEmpty) return;

              final insuranceKey = GlobalKey<InsuranceSheetState>();
              await AppBottomSheet.show(
                context,
                title: S.of(context).insurance,
                contentBuilder: (_) => InsuranceSheet(key: insuranceKey),
                saveLabel: S.of(context).save,
                onSave: () => insuranceKey.currentState?.save(),
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _QuickAddButton(
            icon: Icons.more_horiz,
            iconColor: AppColors.grey700,
            label: S.of(context).more,
            onTap: () => _openMoreSheet(context, carId: carId),
          ),
        ),
      ],
    );
  }

  void _openMoreSheet(BuildContext context, {required String carId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.neutreGreyLight,
                      borderRadius: AppBorders.radiusSmall,
                    ),
                  ),
                ),
                Text(
                  S.of(ctx).add_expense,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.05,
                  children: [
                    _QuickAddButton(
                      icon: Icons.local_car_wash,
                      iconColor: AppColors.catCarWash,
                      label: S.of(ctx).car_wash,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final carWashKey = GlobalKey<CarWashScreenState>();
                        await AppBottomSheet.show<CarWashRecord>(
                          context,
                          title: S.of(context).car_wash,
                          contentBuilder: (_) =>
                              CarWashScreen(key: carWashKey, embedded: true),
                          saveLabel: S.of(context).save,
                          onSave: () => carWashKey.currentState?.save(),
                        );
                      },
                    ),
                    _QuickAddButton(
                      icon: Icons.settings,
                      iconColor: AppColors.catTuning,
                      label: S.of(ctx).tuning,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final tuningKey = GlobalKey<TuningScreenState>();
                        await AppBottomSheet.show<List<TuningRecord>>(
                          context,
                          title: S.of(context).tuning,
                          contentBuilder: (_) =>
                              TuningScreen(key: tuningKey, embedded: true),
                          saveLabel: S.of(context).save,
                          onSave: () => tuningKey.currentState?.save(),
                        );
                      },
                    ),
                    _QuickAddButton(
                      icon: Icons.oil_barrel,
                      iconColor: AppColors.catService,
                      label: S.of(ctx).oil_icon,
                      onTap: () => _openServiceCategorySheet(
                        context,
                        ctx: ctx,
                        category: 'Oil',
                        title: S.of(ctx).oil_icon,
                      ),
                    ),
                    _QuickAddButton(
                      icon: Icons.battery_full,
                      iconColor: AppColors.catService,
                      label: S.of(ctx).battery,
                      onTap: () => _openServiceCategorySheet(
                        context,
                        ctx: ctx,
                        category: 'Battery',
                        title: S.of(ctx).battery,
                      ),
                    ),
                    _QuickAddButton(
                      icon: Icons.tire_repair,
                      iconColor: AppColors.catService,
                      label: S.of(ctx).tires_icon,
                      onTap: () => _openServiceCategorySheet(
                        context,
                        ctx: ctx,
                        category: 'Tires',
                        title: S.of(ctx).tires_icon,
                      ),
                    ),
                    _QuickAddButton(
                      icon: Icons.more_horiz,
                      iconColor: AppColors.catOther,
                      label: S.of(ctx).other,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        final otherKey = GlobalKey<OtherExpenseSheetState>();
                        AppBottomSheet.show<OtherExpenseRecord>(
                          context,
                          title: S.of(context).other,
                          contentBuilder: (_) =>
                              OtherExpenseSheet(key: otherKey),
                          saveLabel: S.of(context).save,
                          onSave: () => otherKey.currentState?.save(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shared by the Oil/Battery/Tires "More" tiles: same [ServiceScreen] as
  /// "ТО", just with its work-list narrowed to [category] - these create a
  /// real expense record, same as Fuel/Service/Car wash/Tuning.
  Future<void> _openServiceCategorySheet(
    BuildContext context, {
    required BuildContext ctx,
    required String category,
    required String title,
  }) async {
    Navigator.of(ctx).pop();
    final serviceKey = GlobalKey<ServiceScreenState>();
    final totalUah = ValueNotifier<double>(0);
    try {
      await AppBottomSheet.show<List<ServiceRecord>>(
        context,
        title: title,
        contentBuilder: (_) => ServiceScreen(
          key: serviceKey,
          embedded: true,
          category: category,
          onTotalChanged: (value) => totalUah.value = value,
        ),
        footerBuilder: (_) => ValueListenableBuilder<double>(
          valueListenable: totalUah,
          builder: (_, total, _) => ServiceTotal(totalUah: total),
        ),
        saveLabel: S.of(context).save,
        onSave: () => serviceKey.currentState?.save(),
      );
    } finally {
      totalUah.dispose();
    }
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // Shared by both the top-level row and the "More" sheet's grid, so
      // every quick-add tile stays uniform and scales with its container's
      // width instead of a fixed pixel height.
      aspectRatio: 1.05,
      child: Material(
        color: AppColors.neutreBlanc,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.radiusMedium,
          side: BorderSide(color: context.brandTheme.surfaceBorder),
        ),
        child: InkWell(
          borderRadius: AppBorders.radiusMedium,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(height: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
