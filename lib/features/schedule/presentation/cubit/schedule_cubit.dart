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
  final String userId;
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
    required this.userId,
    required this.carNumber,
    required this.carCubit,
  }) : super(ScheduleState(tasks: [], loading: true)) {
    _carSub = carCubit.stream.listen((state) {
      final newCar = state.carNumber;
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
    final tasks = await repository.loadTasks(carNumber);
    emit(state.copyWith(tasks: tasks, loading: false));
  }

Future<void> addTask(MaintenanceTask task, {ReminderCubit? reminderCubit}) async {
    if (carNumber.isEmpty) return;

    // --- Guard: если задача с тем же id уже в списке — не добавляем
    if (task.id != null && state.tasks.any((t) => t.id != null && t.id == task.id)) {
      debugPrint("⚠️ Task with same id already exists, skipping add");
      return;
    }

    // --- Guard: если задача с тем же описанием и тем же типом (insurance flag) уже есть — не добавляем
    if (state.tasks.any((t) => t.description == task.description && t.isInsurance == task.isInsurance)) {
      debugPrint("⚠️ Similar task already exists, skipping add");
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
      debugPrint('❌ addTask failed: $e\n$st');
    
      await loadTasks();
    }
  }



  Future<void> updateTask(int index, MaintenanceTask task, {ReminderCubit? reminderCubit}) async {
   if (carNumber.isEmpty) {
      debugPrint("❌ updateTask called with empty carNumber");
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
    debugPrint("🔍 Checking progress for ${task.description}: ${(progress * 100).toStringAsFixed(1)}%");

    if (reminderCubit != null && progress >= 0.9) {
      final reminder = ReminderModel(
        id: const Uuid().v4(),
        title: "${S.current.reminder}: ${task.description}",
        description: _generateDescription(task.description),
        dateTime: DateTime.now().add(const Duration(seconds: 5)),
        isCompleted: false,
        userId: userId,
      );
      await reminderCubit.addReminder(reminder);
      debugPrint("Reminder created for ${task.description}");
    }

    if (progress >= 0.9) {
      await pushHelper.scheduleNotification(
        id: task.description.hashCode,
        title: S.current.resource_out,
        body: '${task.description} ${S.current.reached_usage}',
        dateTime: DateTime.now().add(const Duration(seconds: 5)),
      );
      debugPrint("Notification scheduled for ${task.description}");
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
    emit(state.copyWith(tasks: [], loading: true));
    await loadTasks();
  }

  Future<void> addReminderFromTask(MaintenanceTask task, ReminderCubit? reminderCubit) async {
    final reminder = ReminderModel(
      title: task.description,
      dateTime: task.lastServiceDate ?? DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: '',
      userId: userId,
    );

    await reminderCubit?.addReminder(reminder);
  }

  @override
  Future<void> close() {
    _carSub.cancel();
    return super.close();
  }


}
