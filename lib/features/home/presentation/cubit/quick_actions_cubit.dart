import 'package:bloc/bloc.dart';
import 'package:fines_plus/features/home/domain/entities/quick_action.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';

class QuickActionsCubit extends Cubit<QuickActionsState> {
  QuickActionsCubit(List<QuickAction> initialActions) : super(QuickActionsState(actions: initialActions));

  void selectAction(int index) {
    emit(state.copyWith(selectedIndex: state.selectedIndex == index ? null : index));
  }
}
