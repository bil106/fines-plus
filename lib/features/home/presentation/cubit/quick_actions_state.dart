import 'package:flutter/material.dart';

class QuickActionsState {
  final List<ActionItemModel> actions;
  final List<String> activeCategories;
  final int selectedIndex;
  final bool hasOilTask;
  final Map<String, dynamic>? lastCreatedTaskData;

  QuickActionsState({required this.actions,
    this.activeCategories = const [], this.selectedIndex = -1, this.hasOilTask = false,this.lastCreatedTaskData,});

  QuickActionsState copyWith({List<ActionItemModel>? actions,
    List<String>? activeCategories, int? selectedIndex, bool? hasOilTask,
    Map<String, dynamic>? lastCreatedOilTask,
  }) {
    return QuickActionsState(
      actions: actions ?? this.actions,
       activeCategories: activeCategories ?? this.activeCategories,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      hasOilTask: hasOilTask ?? this.hasOilTask,
      lastCreatedTaskData: lastCreatedOilTask ?? lastCreatedTaskData,
    );
  }
}
class ActionItemModel {
  final String labelKey;
  final IconData icon;

  ActionItemModel({required this.labelKey, required this.icon});
}
