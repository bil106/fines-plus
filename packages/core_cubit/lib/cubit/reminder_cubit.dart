import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/reminder_repository.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;
  final String carNumber;

  ReminderCubit({
    required this.repository,
    required this.carNumber,
  }) : super(ReminderState.initial()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final reminders = await repository.getAll(carNumber);
      emit(state.copyWith(reminders: reminders, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка загрузки: $e',
      ));
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.add(carNumber, reminder);
      await load();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка добавления: $e',
      ));
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.update(carNumber, reminder);
      await load();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка обновления: $e',
      ));
    }
  }

  Future<void> deleteReminder(String id) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.delete(carNumber, id);
      await load();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка удаления: $e',
      ));
    }
  }
}

