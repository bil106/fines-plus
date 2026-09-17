import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_detail_sheet.dart';
import 'package:fines_plus/features/home/presentation/widgets/quick_actions_panel.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
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
    final quickActionsCubit = context.read<QuickActionsCubit>();
    final carId = context.read<CarCubit>().state.carId;

    return Row(
      children: [
        Expanded(
          child: _QuickAddButton(
            dotColor: AppColors.catFuel,
            label: S.of(context).fuel,
            onTap: () async {
              await context.router.push<FuelRecord>(FuelUpRoute());
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _QuickAddButton(
            dotColor: AppColors.catService,
            label: S.of(context).maintenance,
            onTap: () async {
              final records = await Navigator.push<List<ServiceRecord>>(
                context,
                MaterialPageRoute(builder: (_) => const ServiceScreen()),
              );
              if (records != null && records.isNotEmpty) {
                maintenanceCubit.addServiceRecords(records);
              }
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _QuickAddButton(
            dotColor: AppColors.catTuning,
            label: S.of(context).insurance,
            onTap: () async {
              if (carId.isEmpty) return;

              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => const InsuranceDetailSheet(),
              );
              if (result == null) return;

              final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();

              await quickActionsCubit.onTaskCreated(
                {
                  'description': S.maybeOf(context)?.insurance ?? 'Insurance',
                  'category': 'insurance',
                  'isInsurance': true,
                  'date': result['date'] ?? DateTime.now(),
                  'byDate': result['byDate'] ?? true,
                  'intervalDays': result['intervalDays'] ?? 365,
                  'comment': result['comment'] ?? '',
                },
                labelKey: 'Insurance',
                carNumber: carId,
              );

              wrapperState?.openAnalyticsTab(2);
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _QuickAddButton(
            label: S.of(context).more,
            isMore: true,
            onTap: () => _openMoreSheet(context, maintenanceCubit: maintenanceCubit),
          ),
        ),
      ],
    );
  }

  void _openMoreSheet(BuildContext context, {required MaintenanceCubit maintenanceCubit}) {
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
                Text(S.of(ctx).more, style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                _MoreCarWashTile(maintenanceCubit: maintenanceCubit),
                const SizedBox(height: 8),
                // Service/Insurance already have a dedicated top-level
                // button above - don't show them a second time here.
                const QuickActionsPanel(excludeLabelKeys: {'Service', 'Insurance'}),
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
          final record = await context.router.push<CarWashRecord>(CarWashRoute());
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
              Text(S.of(context).car_wash, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final Color? dotColor;
  final String label;
  final VoidCallback onTap;
  final bool isMore;

  const _QuickAddButton({
    this.dotColor,
    required this.label,
    required this.onTap,
    this.isMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutreBlanc,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.radiusMedium,
        side: BorderSide(color: context.brandTheme.surfaceBorder),
      ),
      child: InkWell(
        borderRadius: AppBorders.radiusMedium,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isMore ? '$label ⋯' : '+ $label',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isMore ? AppColors.grey700 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
