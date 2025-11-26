import 'package:bloc/bloc.dart';
import 'package:fines_plus/features/home/data/repositories/tasks_repository.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';
import 'package:flutter/material.dart';

class QuickActionsCubit extends Cubit<QuickActionsState> {
  final TasksRepository tasksRepository;

  QuickActionsCubit(this.tasksRepository)
    : super(
        QuickActionsState(
          actions: [
            ActionItemModel(labelKey: 'Oil', icon: Icons.oil_barrel),
            ActionItemModel(labelKey: 'Coolant', icon: Icons.ac_unit),
            ActionItemModel(labelKey: 'Service', icon: Icons.build),
            ActionItemModel(labelKey: 'Repair', icon: Icons.construction),
            ActionItemModel(labelKey: 'Battery', icon: Icons.battery_full),
            ActionItemModel(labelKey: 'Tuning', icon: Icons.settings),
            ActionItemModel(labelKey: 'Tires', icon: Icons.tire_repair),
            ActionItemModel(labelKey: 'Insurance', icon: Icons.shield),
          ],
        ),
      );
  Future<void> init() async {
    final hasOil = await tasksRepository.hasTaskOfType('oil');
    emit(state.copyWith(hasOilTask: hasOil));
  }

 
Future<void> onTaskCreated(Map<String, dynamic> data, {String? labelKey}) async {
    if (labelKey != null) {
    
      final updated = List<String>.from(state.activeCategories);

    
      if (!updated.contains(labelKey)) {
        updated.add(labelKey);
      }

      if (labelKey.toLowerCase() == 'oil') {
        await tasksRepository.createTask('oil');
        emit(state.copyWith(hasOilTask: true, lastCreatedOilTask: data, activeCategories: updated));
      } else {
        emit(state.copyWith(lastCreatedOilTask: data, activeCategories: updated));
      }
    } else {
      emit(state.copyWith(lastCreatedOilTask: data));
    }
  }



  void clearLastCreatedTaskData() {
    emit(state.copyWith(lastCreatedOilTask: null));
  }

  Future<void> onOilTaskDeleted() async {
    await tasksRepository.removeTask('oil');
    emit(state.copyWith(hasOilTask: false));
  }
  
}

