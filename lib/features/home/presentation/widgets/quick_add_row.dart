import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/widget/app_bottom_sheet.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/other_expense_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_sheet.dart';
import 'package:fines_plus/features/home/presentation/widgets/other_expense_sheet.dart';
import 'package:fines_plus/features/home/presentation/widgets/quick_actions_panel.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The dashboard's "quick add" row: the three most common expense actions
/// (Fuel/Service/Insurance) plus a "More" button for everything else -
/// deliberately not all 8 maintenance categories at once (see
/// QuickActionsPanel), and deliberately no "Add fine" here since fines
/// arrive from the automated check, not a manual entry.
///
/// Replaces the old 4-tile MainExpenseTiles row (Service/CarWash/Fuel/
/// Insurance): same underlying navigation for the three that stayed
/// top-level, Car wash moved into the "More" sheet alongside the rest.
class QuickAddRow extends StatelessWidget {
  const QuickAddRow({super.key});

  @override
  Widget build(BuildContext context) {
    final maintenanceCubit = context.read<MaintenanceCubit>();
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
            onTap: () =>
                _openMoreSheet(context, maintenanceCubit: maintenanceCubit),
          ),
        ),
      ],
    );
  }

  void _openMoreSheet(
    BuildContext context, {
    required MaintenanceCubit maintenanceCubit,
  }) {
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
                _MoreCarWashTile(maintenanceCubit: maintenanceCubit),
                const SizedBox(height: 8),
                const _MoreOtherExpenseTile(),
                const SizedBox(height: 8),
                // Service/Insurance already have a dedicated top-level
                // button above - don't show them a second time here.
                const QuickActionsPanel(
                  excludeLabelKeys: {'Service', 'Insurance'},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoreCarWashTile extends StatelessWidget {
  final MaintenanceCubit maintenanceCubit;
  const _MoreCarWashTile({required this.maintenanceCubit});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutreGrey100,
      borderRadius: AppBorders.radiusMedium,
      child: InkWell(
        borderRadius: AppBorders.radiusMedium,
        onTap: () async {
          Navigator.of(context).pop();
          final record = await context.router.push<CarWashRecord>(
            CarWashRoute(),
          );
          if (record != null) {
            maintenanceCubit.addCarWashRecord(record);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/car-wash.svg',
                color: AppColors.catCarWash,
                colorBlendMode: BlendMode.srcIn,
                height: 22,
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context).car_wash,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreOtherExpenseTile extends StatelessWidget {
  const _MoreOtherExpenseTile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutreGrey100,
      borderRadius: AppBorders.radiusMedium,
      child: InkWell(
        borderRadius: AppBorders.radiusMedium,
        onTap: () {
          Navigator.of(context).pop();
          final otherKey = GlobalKey<OtherExpenseSheetState>();
          AppBottomSheet.show<OtherExpenseRecord>(
            context,
            title: S.of(context).other,
            contentBuilder: (_) => OtherExpenseSheet(key: otherKey),
            saveLabel: S.of(context).save,
            onSave: () => otherKey.currentState?.save(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.more_horiz, color: AppColors.catOther),
              const SizedBox(width: 12),
              Text(
                S.of(context).other,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
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
      // All four tiles share this ratio, so they stay uniform and scale
      // together with the row's width instead of a fixed pixel height.
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
