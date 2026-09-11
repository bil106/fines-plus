import 'package:fines_plus/features/home/domain/entities/action_item_model.dart';

class QuickActionsState {
  final List<ActionItemModel> actions;
  final int selectedIndex;
  final bool hasOilTask;

  final Map<String, List<Map<String, dynamic>>> createdTasks;

  final List<String> activeCategories;

  QuickActionsState({
    required this.actions,
    this.selectedIndex = -1,
    this.hasOilTask = false,
    this.createdTasks = const {},
    this.activeCategories = const [],
  });

  QuickActionsState copyWith({
    List<ActionItemModel>? actions,
    int? selectedIndex,
    bool? hasOilTask,
    Map<String, List<Map<String, dynamic>>>? createdTasks,
    List<String>? activeCategories,
  }) {
    return QuickActionsState(
      actions: actions ?? this.actions,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      hasOilTask: hasOilTask ?? this.hasOilTask,
      createdTasks: createdTasks ?? this.createdTasks,
      activeCategories: activeCategories ?? this.activeCategories,
    );
  }
}

