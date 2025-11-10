import 'dart:async';

import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_data/core_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;
  final PushHelper pushHelper;
  final String userId;

  String carNumber;

  late final StreamSubscription carSubscription;

  ReminderCubit({
    required this.repository,
    required this.pushHelper,
    required this.carNumber,
    required this.userId,
    required CarCubit carCubit,
  }) : super(ReminderState.initial()) {
    
    carSubscription = carCubit.stream.listen((state) {
      if (carNumber != state.carNumber) {
        carNumber = state.carNumber;
        load(); 
      }
    });
    load();
  }

  @override
  Future<void> close() {
    carSubscription.cancel();
    return super.close();
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
    


      await pushHelper.cancelNotification(reminder.id.hashCode);
      

    
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
      dateTime: task.lastServiceDate ?? DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: '',
      userId: userId, 
    );

    await addReminder(reminder);
  }
}



