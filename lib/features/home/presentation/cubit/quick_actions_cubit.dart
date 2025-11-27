import 'package:bloc/bloc.dart';
import 'package:fines_plus/features/home/data/repositories/tasks_repository.dart';
import 'package:fines_plus/features/home/domain/entities/action_item_model.dart';
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

  Future<void> onTaskCreated(Map<String, dynamic> data, {required String labelKey}) async {
    final updatedActive = List<String>.from(state.activeCategories);
    if (!updatedActive.contains(labelKey)) updatedActive.add(labelKey);

    final updatedTasks = Map<String, Map<String, dynamic>>.from(state.createdTasks);
    updatedTasks[labelKey] = data;

    await tasksRepository.createTask(labelKey.toLowerCase());

    emit(
      state.copyWith(
        activeCategories: updatedActive,
        createdTasks: updatedTasks,
        hasOilTask: labelKey.toLowerCase() == 'oil' ? true : state.hasOilTask,
      ),
    );
  }

  void clearCreatedTask(String labelKey) {
    final updatedTasks = Map<String, Map<String, dynamic>>.from(state.createdTasks);
    updatedTasks.remove(labelKey);

    final updatedActive = List<String>.from(state.activeCategories)..remove(labelKey);
    emit(state.copyWith(createdTasks: updatedTasks, activeCategories: updatedActive));
  }

  Future<void> onTaskDeleted(String labelKey) async {
    await tasksRepository.removeTask(labelKey.toLowerCase());
    clearCreatedTask(labelKey);
    if (labelKey.toLowerCase() == 'oil') {
      emit(state.copyWith(hasOilTask: false));
    }
  }
}
