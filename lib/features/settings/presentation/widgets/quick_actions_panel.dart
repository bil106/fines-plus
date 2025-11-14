import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';
import 'package:fines_plus/features/home/presentation/widgets/action_item.dart';
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
            final isOilAction = action.labelKey == 'Oil';
            final isActive = action.labelKey == 'Oil' && state.hasOilTask;

            return ActionItem(
              icon: action.icon,
              label: _translateLabel(action.labelKey, context),
              isSelected: isActive,
              labelKey: action.labelKey,
              onTap: () async {
                final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();

                if (isOilAction) {
                  if (state.hasOilTask) {
                    wrapperState?.openAnalyticsTab(2);
                  } else {
                    wrapperState?.openAnalyticsTab(2);
                  }
                }
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
