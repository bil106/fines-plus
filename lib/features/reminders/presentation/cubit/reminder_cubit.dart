import 'dart:async';

import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/maintenance/data/repository/schedule_firebase_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/domain/auto_reminder_builder.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;
  final String carNumber;
  final String ownerId;
  final PushHelper pushHelper;

  /// Sources of the automatic reminders (insurance, oil change). Optional so
  /// a cubit that only manages manual reminders needn't supply them.
  final MaintenanceCubit? maintenanceCubit;
  final ScheduleFirebaseRepository? scheduleRepository;

  /// On-device copy of the tasks, used when Firestore can't be read/parsed
  /// (same fallback ScheduleCubit uses).
  final ScheduleRepository? scheduleCache;

  StreamSubscription<dynamic>? _maintenanceSub;
  List<MaintenanceTask> _tasks = const [];

  ReminderCubit({
    required this.repository,
    required this.carNumber,
    required this.ownerId,
    required this.pushHelper,
    this.maintenanceCubit,
    this.scheduleRepository,
    this.scheduleCache,
  }) : super(ReminderState.initial()) {
    _maintenanceSub = maintenanceCubit?.stream.listen((_) => _emitReminders(state.reminders));
  }

  Future<void> load() async {
    if (!isClosed) emit(state.copyWith(isLoading: true));

    final reminders = await repository.getAll(carNumber);
    _tasks = await _loadTasks();

    if (!isClosed) emit(state.copyWith(isLoading: false, reminders: reminders, items: _buildItems(reminders)));
  }

  Future<List<MaintenanceTask>> _loadTasks() async {
    if (scheduleRepository == null) return const [];
    try {
      return await scheduleRepository!.loadTasks(carNumber);
    } catch (e, st) {
      debugPrint('ReminderCubit: failed to load maintenance tasks, using local cache: $e\n$st');
      try {
        return await scheduleCache?.loadTasks(carNumber) ?? const [];
      } catch (_) {
        return const [];
      }
    }
  }

  void _emitReminders(List<ReminderModel> reminders) {
    if (isClosed) return;
    emit(state.copyWith(reminders: reminders, items: _buildItems(reminders)));
  }

  List<ReminderItem> _buildItems(List<ReminderModel> reminders) {
    final now = DateTime.now();
    final maintenance = maintenanceCubit?.state;

    final auto = maintenance == null
        ? const <ReminderItem>[]
        : AutoReminderBuilder.build(
            insurance: maintenance.insuranceRecords,
            tasks: _tasks,
            liveMileage: _liveMileage(maintenance),
            mileagePoints: [for (final r in maintenance.fuelRecords) (date: r.date, mileage: r.mileage)],
            now: now,
          );

    const rank = {
      ReminderStatus.overdue: 0,
      ReminderStatus.soon: 1,
      ReminderStatus.upcoming: 2,
      ReminderStatus.done: 3,
    };
    return [...reminders.map(ReminderItem.fromManual), ...auto]
      ..sort((a, b) {
        final byStatus = rank[a.status(now)]!.compareTo(rank[b.status(now)]!);
        return byStatus != 0 ? byStatus : a.sortDays(now).compareTo(b.sortDays(now));
      });
  }

  int _liveMileage(MaintenanceState s) {
    final all = [
      ...s.serviceRecords.map((r) => r.mileage),
      ...s.fuelRecords.map((r) => r.mileage),
      ...s.tuningRecords.map((r) => r.mileage),
      ...s.carWashRecords.map((r) => r.mileage),
    ];
    return all.isEmpty ? 0 : all.reduce((a, b) => a > b ? a : b);
  }

  Future<void> addReminder(ReminderModel reminder) async {
    final updated = [...state.reminders, reminder];
    await repository.add(carNumber, reminder);
    _emitReminders(updated);

    try {
      await pushHelper.scheduleNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description,
        dateTime: reminder.dateTime.toLocal(),
      );
      debugPrint('Notification scheduled for ${reminder.dateTime} with id ${reminder.id}');
    } catch (e, st) {
      debugPrint('Failed to schedule notification for ${reminder.id}: $e\n$st');
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final updated = state.reminders.map((e) => e.id == reminder.id ? reminder : e).toList();
    await repository.update(carNumber, reminder);
    _emitReminders(updated);

    try {
      await pushHelper.scheduleNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description,
        dateTime: reminder.dateTime.toLocal(),
      );
      debugPrint('Notification updated for ${reminder.dateTime} with id ${reminder.id}');
    } catch (e, st) {
      debugPrint('Failed to reschedule notification for ${reminder.id}: $e\n$st');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final updated = state.reminders.where((e) => e.id != reminderId).toList();
    await repository.delete(carNumber, reminderId);
    _emitReminders(updated);
  }

  @override
  Future<void> close() {
    _maintenanceSub?.cancel();
    return super.close();
  }
}
