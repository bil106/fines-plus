import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_detail_sheet.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Same add-expense logic as the FABAction entries on MaintenanceScreen
// (`maintenance_screen.dart`); the Insurance tile reuses the same logic as
// the (now removed from Home) QuickActionsPanel's Insurance entry.
class MainExpenseTiles extends StatelessWidget {
  const MainExpenseTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MaintenanceCubit>();
    final quickActionsCubit = context.read<QuickActionsCubit>();
    // Must be `watch`, not `read` — this widget is returned as a `const`
    // instance from Home, so it only rebuilds with a fresh carId if it
    // subscribes to CarCubit itself.
    final carId = context.watch<CarCubit>().state.carId;

    return Row(
      children: [
        Expanded(
          child: _ExpenseTile(
            icon: const Icon(Icons.build, color: AppColors.energyBlue, size: 34),
            label: S.of(context).service_icon,
            onTap: () async {
              if (carId.isEmpty) {
                await _promptForCarNumber(context);
                return;
              }

              final records = await Navigator.push<List<ServiceRecord>>(
                context,
                MaterialPageRoute(builder: (_) => const ServiceScreen()),
              );
              if (records != null && records.isNotEmpty) {
                cubit.addServiceRecords(records);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ExpenseTile(
            icon: SvgPicture.asset(
              'assets/icons/car-wash.svg',
              color: AppColors.energyBlue,
              colorBlendMode: BlendMode.srcIn,
              height: 34,
            ),
            label: S.of(context).car_wash,
            onTap: () async {
              if (carId.isEmpty) {
                await _promptForCarNumber(context);
                return;
              }

              final record = await context.router.push<CarWashRecord>(CarWashRoute());
              if (record != null) {
                cubit.addCarWashRecord(record);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ExpenseTile(
            icon: const Icon(Icons.local_gas_station, color: AppColors.energyBlue, size: 34),
            label: S.of(context).fuel_up,
            onTap: () async {
              if (carId.isEmpty) {
                await _promptForCarNumber(context);
                return;
              }

              await context.router.push<FuelRecord>(FuelUpRoute());
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ExpenseTile(
            icon: const Icon(Icons.shield, color: AppColors.energyBlue, size: 34),
            label: S.of(context).insurance,
            onTap: () async {
              if (carId.isEmpty) {
                await _promptForCarNumber(context);
                return;
              }

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
      ],
    );
  }
}

Future<void> _promptForCarNumber(BuildContext context) async {
  final controller = TextEditingController();
  final carCubit = context.read<CarCubit>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(S.of(dialogContext).car_number),
        content: TextField(
          controller: controller,
          autofocus: true,
          inputFormatters: [VehicleNumberFormatter()],
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          decoration: InputDecoration(
            hintText: S.of(dialogContext).hint_auto_num,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(S.of(dialogContext).cancel)),
          TextButton(
            onPressed: () {
              carCubit.changeCar(controller.text);
              Navigator.pop(dialogContext);
            },
            child: Text(S.of(dialogContext).save),
          ),
        ],
      );
    },
  );
}

class _ExpenseTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _ExpenseTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.neutreGrey100,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
