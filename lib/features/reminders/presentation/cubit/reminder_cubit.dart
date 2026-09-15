import 'dart:async';

import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;
  final String carNumber;
  final String ownerId;
  final PushHelper pushHelper;

  ReminderCubit({required this.repository, required this.carNumber, required this.ownerId, required this.pushHelper})
    : super(ReminderState.initial());

  Future<void> load() async {
    if (!isClosed) emit(state.copyWith(isLoading: true));

    final reminders = await repository.getAll(carNumber);

    if (!isClosed) emit(state.copyWith(isLoading: false, reminders: reminders));
  }

  Future<void> addReminder(ReminderModel reminder) async {
    final updated = [...state.reminders, reminder];
    await repository.add(carNumber, reminder);
    emit(state.copyWith(reminders: updated));

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
    emit(state.copyWith(reminders: updated));

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
    emit(state.copyWith(reminders: updated));
  }
}
