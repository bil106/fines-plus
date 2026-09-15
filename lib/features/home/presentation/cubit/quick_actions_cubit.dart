import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fines_plus/features/home/data/repositories/tasks_repository.dart';
import 'package:fines_plus/features/home/domain/entities/action_item_model.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickActionsCubit extends Cubit<QuickActionsState> {
  final TasksRepository tasksRepository;
  final SharedPreferences prefs;
  StreamSubscription<List<String>>? _activeCategoriesSub;

  QuickActionsCubit(this.tasksRepository, this.prefs)
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
          activeCategories: prefs.getStringList('activeCategories') ?? [],
        ),
      );

  Future<void> init() async {
    final hasOil = await tasksRepository.hasTaskOfType('oil');
    emit(state.copyWith(hasOilTask: hasOil));
  }

  Future<void> onTaskCreated(Map<String, dynamic> data, {required String labelKey, required String carNumber}) async {
    if (carNumber.isEmpty) return;

    final key = labelKey.toLowerCase();

    await tasksRepository.createTask(key, carNumber: carNumber);

    final updatedActive = List<String>.from(state.activeCategories);
    if (!updatedActive.contains(key)) updatedActive.add(key);

    final updatedTasks = Map<String, List<Map<String, dynamic>>>.from(state.createdTasks);
    updatedTasks[key] = List<Map<String, dynamic>>.from(updatedTasks[key] ?? []);
    updatedTasks[key]!.add(data);

    emit(state.copyWith(activeCategories: updatedActive, createdTasks: updatedTasks));
    await prefs.setStringList('activeCategories', updatedActive);
  }

  void clearCreatedTask(String labelKey) {
    final key = labelKey.toLowerCase();
    final updatedTasks = Map<String, List<Map<String, dynamic>>>.from(state.createdTasks);
    updatedTasks.remove(key);

    final updatedActive = List<String>.from(state.activeCategories)..remove(key);
    emit(state.copyWith(createdTasks: updatedTasks, activeCategories: updatedActive));
  }

  Future<void> onTaskDeleted(String category) async {
    final updatedCreatedTasks = Map.of(state.createdTasks);
    updatedCreatedTasks.remove(category);

    final updatedActiveCategories = Set<String>.from(state.activeCategories);
    updatedActiveCategories.remove(category.toLowerCase());

    emit(state.copyWith(createdTasks: updatedCreatedTasks, activeCategories: updatedActiveCategories.toList()));
  }

  Future<void> syncWithRepository() async {
    final updated = <String>[];

    for (final action in state.actions) {
      final key = action.labelKey.toLowerCase();
      final hasTask = await tasksRepository.hasTaskOfType(key);
      if (hasTask) updated.add(key);
    }

    emit(state.copyWith(activeCategories: updated));
    await prefs.setStringList('activeCategories', updated);
  }

  void onExternalTaskDeleted(String labelKey) {
    final updatedActive = List<String>.from(state.activeCategories)..remove(labelKey);

    final updatedTasks = Map<String, List<Map<String, dynamic>>>.from(state.createdTasks);
    updatedTasks.remove(labelKey);

    emit(state.copyWith(activeCategories: updatedActive, createdTasks: updatedTasks));

    prefs.setStringList('activeCategories', updatedActive);
  }

  void markTaskDeleted(String labelKey) {
    if (state.createdTasks.containsKey(labelKey)) {
      for (var task in state.createdTasks[labelKey]!) {
        task['deleted'] = true;
      }
      emit(state.copyWith(createdTasks: state.createdTasks));
    }
  }

  void clearAllActive() {
    emit(state.copyWith(activeCategories: [], createdTasks: {}));
  }

  Future<void> syncActiveCategories(String carNumber) async {
    if (carNumber.isEmpty) return;

    final activeCategories = <String>[];

    for (final action in state.actions) {
      final key = action.labelKey.toLowerCase();
      final hasActive = await tasksRepository.hasActiveTask(carNumber: carNumber, category: key);

      if (hasActive) {
        activeCategories.add(key);
      }
    }

    emit(state.copyWith(activeCategories: activeCategories));
  }

  /// Keeps [activeCategories] live-synced with Firestore for [carNumber] —
  /// a quick-action task created/removed on another device (or another
  /// screen on this one) is reflected here immediately, instead of only on
  /// the next explicit [syncActiveCategories] call.
  void listenToActiveCategories(String carNumber) {
    _activeCategoriesSub?.cancel();
    if (carNumber.isEmpty) {
      emit(state.copyWith(activeCategories: []));
      return;
    }

    _activeCategoriesSub = tasksRepository.watchActiveCategories(carNumber: carNumber).listen((categories) {
      emit(state.copyWith(activeCategories: categories));
      prefs.setStringList('activeCategories', categories);
    });
  }

  void removeCategoryLocally(String labelKey) {
    final key = labelKey.toLowerCase();

    final updatedTasks = Map<String, List<Map<String, dynamic>>>.from(state.createdTasks);
    updatedTasks.remove(key);

    final updatedActive = List<String>.from(state.activeCategories)..remove(key);

    emit(state.copyWith(createdTasks: updatedTasks, activeCategories: updatedActive));

    prefs.setStringList('activeCategories', updatedActive);
  }

  void activateCategory(String labelKey) {
    final key = labelKey.toLowerCase();
    if (!state.activeCategories.contains(key)) {
      emit(state.copyWith(activeCategories: [...state.activeCategories, key]));
    }
  }

  void deactivateCategory(String labelKey) {
    final key = labelKey.toLowerCase();
    emit(state.copyWith(activeCategories: state.activeCategories.where((e) => e != key).toList()));
  }

  void updateActiveCategoriesFromTasks(List<String> categories) {
    final uniqueCategories = categories.map((e) => e.toLowerCase()).toSet().toList();
    emit(state.copyWith(activeCategories: uniqueCategories));

    prefs.setStringList('activeCategories', uniqueCategories);
  }

  @override
  Future<void> close() {
    _activeCategoriesSub?.cancel();
    return super.close();
  }
}
