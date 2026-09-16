import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';
import 'package:fines_plus/features/home/presentation/widgets/action_item.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_detail_sheet.dart';
import 'package:fines_plus/features/schedule/presentation/widgets/action_detail_sheet.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickActionsPanel extends StatelessWidget {
  // Labels to hide, e.g. when a caller already offers a dedicated entry
  // point for that category elsewhere (see the dashboard's quick-add row +
  // "more" sheet, which excludes 'Service'/'Insurance' this way).
  final Set<String> excludeLabelKeys;

  const QuickActionsPanel({super.key, this.excludeLabelKeys = const {}});

  @override
  Widget build(BuildContext context) {
    final carCubit = context.watch<CarCubit?>();
    final carId = carCubit?.state.carId ?? '';
    final hasCar = carId.isNotEmpty;

    final quickActionsCubit = context.read<QuickActionsCubit?>();
    if (quickActionsCubit == null) return const SizedBox.shrink();

    return BlocBuilder<QuickActionsCubit, QuickActionsState>(
      builder: (context, state) {
        final actions = state.actions
            .where((a) => !excludeLabelKeys.contains(a.labelKey))
            .toList();
        if (actions.isEmpty) {
          return const SizedBox.shrink();
        }

        return GridView.builder(
          shrinkWrap: true,
          itemCount: actions.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 1.68,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];

            final isActive =
                hasCar && state.activeCategories.map((e) => e.toLowerCase()).contains(action.labelKey.toLowerCase());

            return ActionItem(
              icon: action.icon,
              label: _translateLabel(action.labelKey, context),
              isSelected: isActive,
              labelKey: action.labelKey,
              onTap: () async {
                if (!hasCar) return;

                final labelKey = action.labelKey;
                final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();

                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) {
                    if (labelKey == "Insurance") {
                      return const InsuranceDetailSheet();
                    } else {
                      return ActionDetailSheet(
                        description: _translateLabel(labelKey, ctx),
                        category: labelKey,
                        byDate: false,
                        byMileage: true,
                      );
                    }
                  },
                );

                if (result == null) return;

                if (labelKey == "Insurance") {
                  await quickActionsCubit.onTaskCreated(
                    {
                      'description': S.maybeOf(context)?.insurance ?? labelKey,
                      'category': labelKey.toLowerCase(),
                      'isInsurance': true,
                      'date': result['date'] ?? DateTime.now(),
                      'byDate': result['byDate'] ?? true,
                      'intervalDays': result['intervalDays'] ?? 365,
                      'comment': result['comment'] ?? '',
                    },
                    labelKey: labelKey,
                    carNumber: carId,
                  );
                } else {
                  await quickActionsCubit.onTaskCreated(result, labelKey: labelKey, carNumber: carId);
                }

                wrapperState?.openAnalyticsTab(2);
              },
            );
          },
        );
      },
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
