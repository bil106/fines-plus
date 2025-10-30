import 'package:bloc/bloc.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;
  final MaintenanceCubit maintenanceCubit;
  final PushHelper pushHelper;
  final String userId; // ✅ добавляем userId
  bool enabled;

  ScheduleCubit({
    required this.repository,
    required this.maintenanceCubit,
    required this.pushHelper,
    required this.enabled,
    required this.userId, // ✅ добавляем в конструктор
  }) : super(ScheduleState(tasks: []));

  Future<void> loadTasks() async {
    final tasks = await repository.loadTasks();
    emit(state.copyWith(tasks: tasks));
  }

  void addTask(MaintenanceTask task, {ReminderCubit? reminderCubit}) async {
    final updatedTasks = List<MaintenanceTask>.from(state.tasks)..add(task);
    emit(state.copyWith(tasks: updatedTasks));

    await repository.saveTasks(updatedTasks);

    if (reminderCubit != null && task.intervalTime != null) {
      // ✅ передаем userId
      await reminderCubit.addReminderFromTask(task);
    }
  }

  Future<void> updateTask(int index, MaintenanceTask task, {ReminderCubit? reminderCubit}) async {
    final updatedTasks = List<MaintenanceTask>.from(state.tasks);
    if (index >= 0 && index < updatedTasks.length) {
      updatedTasks[index] = task;
      emit(state.copyWith(tasks: updatedTasks));
      await repository.saveTasks(updatedTasks);

      await _checkTask(task, reminderCubit);
    }
  }

  Future<void> _checkTask(MaintenanceTask task, ReminderCubit? reminderCubit) async {
    final progress = task.getProgress();
    debugPrint("🔍 Checking progress for ${task.title}: ${(progress * 100).toStringAsFixed(1)}%");

    if (reminderCubit != null && progress >= 0.9) {
      final reminder = ReminderModel(
        id: const Uuid().v4(),
        title: "${S.current.reminder}: ${task.title}",
        description: _generateDescription(task.title),
        dateTime: DateTime.now().add(const Duration(seconds: 5)),
        isCompleted: false,
        userId: userId, // ✅ передаем userId
      );
      await reminderCubit.addReminder(reminder);
      debugPrint("Reminder created for ${task.title}");
    }

    if (progress >= 0.9) {
      await pushHelper.scheduleNotification(
        id: task.title.hashCode,
        title: S.current.resource_out,
        body: '${task.title} ${S.current.reached_usage}',
        dateTime: DateTime.now().add(const Duration(seconds: 5)),
      );
      debugPrint("Notification scheduled for ${task.title}");
    }
  }

  Future<void> removeTask(int index, {ReminderCubit? reminderCubit}) async {
    final updatedTasks = List<MaintenanceTask>.from(state.tasks)..removeAt(index);
    emit(state.copyWith(tasks: updatedTasks));
    await repository.saveTasks(updatedTasks);
  }

  String _generateDescription(String title) {
    final lower = title.toLowerCase();
    if (lower.contains(S.current.oil)) return S.current.not_forget;
    if (lower.contains(S.current.tires)) return S.current.check_tires;
    if (lower.contains(S.current.filter)) return S.current.check_filter;
    return "${S.current.not_forget_task}: $title";
  }
}
