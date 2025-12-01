import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';
import 'package:fines_plus/features/home/presentation/widgets/action_item.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_detail_sheet.dart';
import 'package:fines_plus/features/schedule/presentation/widgets/action_detail_sheet.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuickActionsCubit, QuickActionsState>(
      builder: (context, state) {
        return GridView.builder(
          shrinkWrap: true,
          itemCount: state.actions.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 1.52,
          ),
          itemBuilder: (context, index) {
            final action = state.actions[index];
            final isActive = state.activeCategories.contains(action.labelKey);

            return ActionItem(
              icon: action.icon,
              label: _translateLabel(action.labelKey, context),
              isSelected: isActive,
              labelKey: action.labelKey,
              onTap: () async {
                final labelKey = action.labelKey;
                final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();

                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) {
                    if (action.labelKey == "Insurance") {
                      return const InsuranceDetailSheet();
                    } else {
                      return ActionDetailSheet(
                        description: _translateLabel(action.labelKey, context),
                        category: action.labelKey,
                        byDate: false,
                        byMileage: true,
                      );
                    }
                  },
                );

                if (result == null) return;

                final quick = context.read<QuickActionsCubit>();

                if (labelKey == "Insurance") {
                  await quick.onTaskCreated({
                    'description': S.of(context).insurance,
                    'isInsurance': true,
                    'date': result['date'] ?? DateTime.now(),
                    'byDate': result['byDate'] ?? true,
                    'intervalDays': result['intervalDays'] ?? 365,
                    'comment': result['comment'] ?? '',
                  }, labelKey: labelKey);
                } else {
                  await quick.onTaskCreated(result, labelKey: labelKey);
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
