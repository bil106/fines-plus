import 'package:flutter/material.dart';

class QuickActionsState {
  final List<ActionItemModel> actions;
  final int selectedIndex;
  final bool hasOilTask;

  QuickActionsState({required this.actions, this.selectedIndex = -1, this.hasOilTask = false});

  QuickActionsState copyWith({List<ActionItemModel>? actions, int? selectedIndex, bool? hasOilTask}) {
    return QuickActionsState(
      actions: actions ?? this.actions,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      hasOilTask: hasOilTask ?? this.hasOilTask,
    );
  }
}
class ActionItemModel {
  final String labelKey;
  final IconData icon;

  ActionItemModel({required this.labelKey, required this.icon});
}
