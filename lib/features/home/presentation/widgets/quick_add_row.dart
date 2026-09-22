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
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/tuning_screen.dart';
import 'package:fines_plus/features/reminders/domain/maintenance_ring.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
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
          child: BlocBuilder<ReminderCubit, ReminderState>(
            buildWhen: (previous, current) =>
                previous.reminders != current.reminders,
            builder: (context, reminderState) => _QuickAddButton(
              icon: Icons.assignment_turned_in,
              iconColor: AppColors.catService,
              label: S.of(context).maintenance,
              ring: MaintenanceRing.plannedRemaining(
                reminderState.reminders,
                DateTime.now(),
              ),
              onTap: () async {
                final serviceKey = GlobalKey<ServiceScreenState>();
                // ServiceScreen self-saves via MaintenanceCubit when embedded
                // (see its `embedded` doc comment) - no need to await/save a
                // popped list here, unlike the full-screen route.
                await AppBottomSheet.show<List<ServiceRecord>>(
                  context,
                  title: S.of(context).maintenance,
                  contentBuilder: (_) => ServiceScreen(
                    key: serviceKey,
                    embedded: true,
                    reminderCubit: context.read<ReminderCubit>(),
                  ),
                  saveLabel: S.of(context).save,
                  onSave: () => serviceKey.currentState?.save(),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: BlocBuilder<ReminderCubit, ReminderState>(
            buildWhen: (previous, current) =>
                previous.items != current.items ||
                previous.tasks != current.tasks,
            builder: (context, reminderState) => _QuickAddButton(
              icon: Icons.gpp_good,
              iconColor: AppColors.catInsurance,
              label: S.of(context).insurance,
              ring: MaintenanceRing.insuranceRemaining(
                context.read<MaintenanceCubit>().state.insuranceRecords,
                reminderState.tasks,
                DateTime.now(),
              ),
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
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _QuickAddButton(
            icon: Icons.more_horiz,
            iconColor: AppColors.catOther,
            label: S.of(context).more,
            labelColor: AppColors.textSecondary,
            onTap: () => _openMoreSheet(context, carId: carId),
          ),
        ),
      ],
    );
  }

  void _openMoreSheet(BuildContext context, {required String carId}) {
    // The sheet is built above the Home providers, so hand it the cubit.
    final reminderCubit = context.read<ReminderCubit>();
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
                      color: context.brandTheme.surfaceBorder,
                      borderRadius: AppBorders.radiusSmall,
                    ),
                  ),
                ),
                Text(
                  S.of(ctx).add_expense,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
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
                    _PlannedTile(
                      cubit: reminderCubit,
                      category: TuningScreen.plannedCategory,
                      icon: Icons.settings,
                      iconColor: AppColors.catTuning,
                      label: S.of(ctx).tuning,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final tuningKey = GlobalKey<TuningScreenState>();
                        await AppBottomSheet.show<List<TuningRecord>>(
                          context,
                          title: S.of(context).tuning,
                          contentBuilder: (_) => TuningScreen(
                            key: tuningKey,
                            embedded: true,
                            reminderCubit: reminderCubit,
                          ),
                          saveLabel: S.of(context).save,
                          onSave: () => tuningKey.currentState?.save(),
                        );
                      },
                    ),
                    _PlannedTile(
                      cubit: reminderCubit,
                      category: 'Oil',
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
                    _PlannedTile(
                      cubit: reminderCubit,
                      category: 'Battery',
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
                    _PlannedTile(
                      cubit: reminderCubit,
                      category: 'Tires',
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
                      iconColor: AppColors.textSecondary,
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
    await AppBottomSheet.show<List<ServiceRecord>>(
      context,
      title: title,
      contentBuilder: (_) => ServiceScreen(
        key: serviceKey,
        embedded: true,
        category: category,
        reminderCubit: context.read<ReminderCubit>(),
      ),
      saveLabel: S.of(context).save,
      onSave: () => serviceKey.currentState?.save(),
    );
  }
}

/// A "More" sheet tile with a progress ring for its own service category.
class _PlannedTile extends StatelessWidget {
  final ReminderCubit cubit;
  final String category;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _PlannedTile({
    required this.cubit,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderCubit, ReminderState>(
      bloc: cubit,
      buildWhen: (previous, current) => previous.reminders != current.reminders,
      builder: (context, state) => _QuickAddButton(
        icon: icon,
        iconColor: iconColor,
        label: label,
        ring: MaintenanceRing.plannedRemaining(
          state.reminders,
          DateTime.now(),
          category: category,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  /// Share of the service / policy interval still left (see
  /// [MaintenanceRing]); draws a progress ring around the icon when set.
  final double? ring;

  /// Label color - defaults to [AppColors.ink]; the "More" tile uses a
  /// muted secondary color instead, per the mockup.
  final Color labelColor;

  const _QuickAddButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.ring,
    this.labelColor = AppColors.ink,
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
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: context.brandTheme.surfaceBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ring == null
                    ? Icon(icon, color: iconColor, size: 20)
                    : _RingIcon(
                        icon: icon,
                        iconColor: iconColor,
                        remaining: ring!,
                      ),
                const SizedBox(height: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        color: labelColor,
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

/// The tile icon inside a progress ring: the arc is the share still left,
/// coloured by [MaintenanceRing.color].
class _RingIcon extends StatelessWidget {
  static const _size = 28.0;

  final IconData icon;
  final Color iconColor;
  final double remaining;

  const _RingIcon({
    required this.icon,
    required this.iconColor,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: remaining.clamp(0.0, 1.0),
              strokeWidth: 2.5,
              backgroundColor: context.brandTheme.surfaceBorder,
              color: MaintenanceRing.color(
                remaining,
                danger: context.brandTheme.statusDanger,
                warning: context.brandTheme.statusWarning,
                success: context.brandTheme.statusSuccess,
              ),
            ),
          ),
          Icon(icon, color: iconColor, size: 15),
        ],
      ),
    );
  }
}
