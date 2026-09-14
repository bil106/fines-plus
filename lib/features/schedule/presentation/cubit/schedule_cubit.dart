import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/maintenance/data/repository/schedule_firebase_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;
  final ScheduleFirebaseRepository firebaseRepo;
  final MaintenanceCubit maintenanceCubit;
  final PushHelper pushHelper;
  final String ownerId;
  String carNumber;
  final CarCubit carCubit;
  late final StreamSubscription _carSub;
  bool enabled;

  ScheduleCubit({
    required this.repository,
    required this.firebaseRepo,
    required this.maintenanceCubit,
    required this.pushHelper,
    required this.enabled,
    required this.ownerId,
    required this.carNumber,
    required this.carCubit,
  }) : super(ScheduleState(tasks: [], loading: true)) {
    _carSub = carCubit.stream.listen((state) {
      final newCar = state.carId;
      if (newCar != carNumber) {
        onCarChanged(newCar);
      }
    });

    if (carNumber.isNotEmpty) {
      loadTasks();
    }
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(loading: true));

    try {
      await firebaseRepo.migrateLegacyIfNeeded(carNumber);
      var tasks = await firebaseRepo.loadTasks(carNumber);

      if (tasks.isEmpty) {
        final localTasks = await repository.loadTasks(carNumber);
        if (localTasks.isNotEmpty) {
          for (final task in localTasks) {
            await firebaseRepo.saveTask(carNumber, task);
          }
          tasks = await firebaseRepo.loadTasks(carNumber);
        }
      }

      await repository.saveTasks(carNumber, tasks);
      emit(state.copyWith(tasks: tasks, loading: false));
    } catch (e, st) {
      debugPrint('loadTasks from Firestore failed, falling back to local cache: $e\n$st');
      final localTasks = await repository.loadTasks(carNumber);
      emit(state.copyWith(tasks: localTasks, loading: false));
    }
  }

  Future<void> addTask(MaintenanceTask task, {ReminderCubit? reminderCubit}) async {
    if (carNumber.isEmpty) return;

    if (task.id != null && state.tasks.any((t) => t.id != null && t.id == task.id)) {
      return;
    }

    if (state.tasks.any((t) => t.description == task.description && t.isInsurance == task.isInsurance)) {
      return;
    }

    var updatedTasks = List<MaintenanceTask>.from(state.tasks)..add(task);
    emit(state.copyWith(tasks: updatedTasks));

    try {
      final savedTask = await firebaseRepo.saveTask(carNumber, task);

      updatedTasks = List<MaintenanceTask>.from(state.tasks)
        ..removeWhere(
          (t) =>
              (t.id == null || t.id!.isEmpty) && t.description == task.description && t.isInsurance == task.isInsurance,
        )
        ..add(savedTask);

      await repository.saveTasks(carNumber, updatedTasks);
      emit(state.copyWith(tasks: updatedTasks));
      await _checkTask(savedTask, reminderCubit);
    } catch (e, st) {
      debugPrint('addTask failed: $e\n$st');
      // Revert the optimistic update — task was not persisted
      final revertedTasks = List<MaintenanceTask>.from(state.tasks)
        ..removeWhere((t) =>
            (t.id == null || t.id!.isEmpty) &&
            t.description == task.description &&
            t.isInsurance == task.isInsurance);
      await repository.saveTasks(carNumber, revertedTasks);
      emit(state.copyWith(tasks: revertedTasks));
    }
  }

  Future<void> updateTask(int index, MaintenanceTask task, {ReminderCubit? reminderCubit}) async {
    if (carNumber.isEmpty) {
      return;
    }
    final updatedTasks = List<MaintenanceTask>.from(state.tasks);
    if (index >= 0 && index < updatedTasks.length) {
      updatedTasks[index] = task;
      emit(state.copyWith(tasks: updatedTasks));
      await repository.saveTasks(carNumber, updatedTasks);
      await firebaseRepo.updateTask(carNumber, task);
      await _checkTask(task, reminderCubit);
    }
  }

  Future<void> _checkTask(MaintenanceTask task, ReminderCubit? reminderCubit) async {
    final progress = task.getProgress();
    debugPrint("Checking progress for ${task.description}: ${(progress * 100).toStringAsFixed(1)}%");

    if (task.description.trim().isNotEmpty && progress >= 0.9) {
      if (reminderCubit != null) {
        final reminder = ReminderModel(
          id: const Uuid().v4(),
          title: "${S.current.reminder}: ${task.description}",
          description: _generateDescription(task.description),
          dateTime: DateTime.now().add(const Duration(seconds: 5)),
          isCompleted: false,
          ownerId: ownerId,
        );
        await reminderCubit.addReminder(reminder);
        debugPrint("Reminder created for ${task.description}");
      }

      final notifId = task.id.hashCode.abs() % 100000;
      final body = progress >= 1.0
          ? '${S.current.reminder}: ${task.description}'
          : S.current.maintenance_due_body(task.description);
      await pushHelper.showNow(
        id: notifId,
        title: S.current.maintenance_due_title,
        body: body,
        isMaintenance: true,
      );
    }
  }

  Future<void> removeTask(int index, {ReminderCubit? reminderCubit, QuickActionsCubit? quickActionsCubit}) async {
    if (carNumber.isEmpty) return;
    if (index < 0 || index >= state.tasks.length) return;

    final removedTask = state.tasks[index];
    debugPrint('removeTask called index=$index id=${removedTask.id} category=${removedTask.category}');

    final updatedTasks = List<MaintenanceTask>.from(state.tasks)..removeAt(index);

    emit(state.copyWith(tasks: updatedTasks, tasksRemoved: [removedTask]));

    await Future.wait([
      repository.saveTasks(carNumber, updatedTasks),
      firebaseRepo.deleteTask(carNumber, removedTask),
      if (reminderCubit != null) reminderCubit.deleteReminder(removedTask.id?.toString() ?? ""),
    ]);
  }

  String _generateDescription(String title) {
    final lower = title.toLowerCase();
    if (lower.contains(S.current.oil)) return S.current.not_forget;
    if (lower.contains(S.current.tires)) return S.current.check_tires;
    if (lower.contains(S.current.filter)) return S.current.check_filter;
    return "${S.current.not_forget_task}: $title";
  }

  Future<void> onCarChanged(String newCar) async {
    carNumber = newCar;
    if (newCar.isEmpty) {
      emit(state.copyWith(tasks: [], loading: false));
      return;
    }
    emit(state.copyWith(tasks: [], loading: true));
    await loadTasks();
  }

  Future<void> addReminderFromTask(MaintenanceTask task, ReminderCubit? reminderCubit) async {
    final reminder = ReminderModel(
      title: task.description,
      dateTime: task.lastServiceDate ?? DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: '',
      ownerId: ownerId,
    );

    await reminderCubit?.addReminder(reminder);
  }

  @override
  Future<void> close() {
    _carSub.cancel();
    return super.close();
  }
}
