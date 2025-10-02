import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;
  final PushHelper pushHelper;
  final String carNumber;

  ReminderCubit({
    required this.repository,
    required this.pushHelper,
    required this.carNumber,
  }) : super(ReminderState.initial()) {
    load();
  }

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final reminders = await repository.getAll(carNumber);
      if (!isClosed) emit(state.copyWith(reminders: reminders, isLoading: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(isLoading: false, errorMessage: 'Loading error: $e'));
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.add(carNumber, reminder);

      final prefs = await SharedPreferences.getInstance();
      final remindersEnabled = prefs.getBool("reminders") ?? true;
      final pushEnabled = prefs.getBool("pushNotifications") ?? true;

      if (remindersEnabled && pushEnabled) {
        await pushHelper.scheduleNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description,
          dateTime: reminder.dateTime,
        );
      }

      await load();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Adding error: $e'));
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.update(carNumber, reminder);
      await load();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Update error: $e'));
    }
  }

  Future<void> deleteReminder(String id) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.delete(carNumber, id);
      await load();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Delete error: $e'));
    }
  }

  Future<void> addReminderFromTask(MaintenanceTask task) async {
    if (task.intervalTime == null) return;

    final reminder = ReminderModel(
      title: task.title,
      dateTime: task.lastServiceDate != null ? DateTime.parse(task.lastServiceDate!) : DateTime.now(),
      id: '',
      description: '',
    );

    await addReminder(reminder);
  }
}
