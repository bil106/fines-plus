import 'package:fines_plus/features/home/domain/entities/quick_action.dart';

class QuickActionsState {
  final List<QuickAction> actions;
  final int? selectedIndex;

  const QuickActionsState({required this.actions, this.selectedIndex});

  QuickActionsState copyWith({List<QuickAction>? actions, int? selectedIndex}) {
    return QuickActionsState(actions: actions ?? this.actions, selectedIndex: selectedIndex);
  }
}
