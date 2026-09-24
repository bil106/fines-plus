import 'dart:async';

import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/maintenance/data/repository/schedule_firebase_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/domain/auto_reminder_builder.dart';
import 'package:fines_plus/features/reminders/domain/insurance_expiry_reminder.dart';
import 'package:fines_plus/features/reminders/domain/planned_service.dart';
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

  /// End date the insurance notification is currently scheduled for, so it is
  /// only re-scheduled when that date actually changes.
  DateTime? _insuranceNotifiedFor;

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

    if (!isClosed) {
      final items = _buildItems(reminders);
      emit(state.copyWith(isLoading: false, reminders: reminders, items: items, tasks: _tasks));
      unawaited(_syncInsuranceNotification(items));
      unawaited(_resyncLocalNotifications(reminders));
    }
  }

  /// Local notifications are OS-level and per-device - a reminder created
  /// on one device is otherwise never (re)scheduled on another device that
  /// only ever sees it through Firestore sync (see [ReminderRepository]).
  /// Re-establishing the schedule for every not-yet-completed reminder each
  /// time the list loads means whichever device has the app open before a
  /// reminder is due still fires it, regardless of where it was created.
  /// Idempotent: [PushHelper.scheduleNotification] just replaces the
  /// existing OS-level schedule for the same id.
  Future<void> _resyncLocalNotifications(List<ReminderModel> reminders) async {
    for (final reminder in reminders) {
      if (reminder.isCompleted) continue;
      try {
        await pushHelper.scheduleNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description,
          dateTime: reminder.dateTime.toLocal(),
        );
        await _syncPlannedDaily(reminder);
      } catch (e, st) {
        debugPrint('Failed to resync notification for ${reminder.id}: $e\n$st');
      }
    }
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
    final items = _buildItems(reminders);
    emit(state.copyWith(reminders: reminders, items: items));
    unawaited(_syncInsuranceNotification(items));
  }

  Future<void> _syncInsuranceNotification(List<ReminderItem> items) async {
    if (maintenanceCubit == null) return;
    final dueDate = items.where((item) => item.kind == ReminderKind.insurance).firstOrNull?.dueDate;
    if (dueDate == _insuranceNotifiedFor) return;
    _insuranceNotifiedFor = dueDate;
    try {
      await InsuranceExpiryReminder(pushHelper).sync(dueDate);
    } catch (e, st) {
      debugPrint('Failed to schedule insurance expiry notification: $e\n$st');
    }
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
      await _syncPlannedDaily(reminder);
    } catch (e, st) {
      debugPrint('Failed to schedule notification for ${reminder.id}: $e\n$st');
    }
  }

  /// Books each of [names] as a planned service on [date] (no cost, no
  /// expense) for the quick-add sheet of [category].
  Future<void> addPlannedServices({required List<String> names, required DateTime date, String? category}) async {
    final due = DateTime(date.year, date.month, date.day, PlannedService.reminderHour);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < names.length; i++) {
      await addReminder(
        ReminderModel(
          id: '${stamp}_$i',
          title: names[i],
          description: S.current.planned_service_reminder_body,
          dateTime: due,
          ownerId: ownerId,
          isPlannedService: true,
          plannedCategory: category,
        ),
      );
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
      await _syncPlannedDaily(reminder);
    } catch (e, st) {
      debugPrint('Failed to reschedule notification for ${reminder.id}: $e\n$st');
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final updated = state.reminders.where((e) => e.id != reminderId).toList();
    await repository.delete(carNumber, reminderId);
    _emitReminders(updated);
    await pushHelper.cancelNotification(reminderId.hashCode);
    await _cancelPlannedDaily(reminderId);
  }

  Future<void> _cancelPlannedDaily(String reminderId) async {
    await pushHelper.cancelNotification(PlannedService.dailyNotificationId(reminderId));
    for (var days = 1; days <= PlannedService.leadDays; days++) {
      await pushHelper.cancelNotification(PlannedService.leadNotificationId(reminderId, days));
    }
  }

  /// A planned service reminds every day at the same time starting
  /// [PlannedService.leadDays] before its date, and keeps nagging after it
  /// until it's completed or deleted.
  ///
  /// A daily repeat only matches the time of day - the OS ignores the date
  /// of its first occurrence - so it's armed only once that first occurrence
  /// is less than a day away. Until then the days before the date get
  /// one-off notifications, and the next app load arms the daily repeat.
  Future<void> _syncPlannedDaily(ReminderModel reminder) async {
    await _cancelPlannedDaily(reminder.id);
    if (!reminder.isPlannedService || reminder.isCompleted) return;

    final now = DateTime.now();
    final due = reminder.dateTime.toLocal();
    var first = due.subtract(const Duration(days: PlannedService.leadDays));
    while (first.isBefore(now)) {
      first = first.add(const Duration(days: 1));
    }

    if (first.difference(now) < const Duration(days: 1)) {
      // The daily repeat also covers the due date itself.
      await pushHelper.cancelNotification(reminder.id.hashCode);
      await pushHelper.scheduleDailyNotification(
        id: PlannedService.dailyNotificationId(reminder.id),
        title: reminder.title,
        body: reminder.description,
        firstDate: first,
      );
      return;
    }

    for (var days = 1; days <= PlannedService.leadDays; days++) {
      await pushHelper.scheduleNotification(
        id: PlannedService.leadNotificationId(reminder.id, days),
        title: reminder.title,
        body: S.current.planned_service_lead_reminder_body(days),
        dateTime: due.subtract(Duration(days: days)),
      );
    }
  }

  @override
  Future<void> close() {
    _maintenanceSub?.cancel();
    return super.close();
  }
}
