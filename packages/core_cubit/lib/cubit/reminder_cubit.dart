import 'package:core_data/core_data.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;

  ReminderCubit(this.repository) : super(ReminderState.initial()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final reminders = await repository.getAll();
    emit(state.copyWith(reminders: reminders, isLoading: false));
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await repository.add(reminder);
    await load();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await repository.update(reminder);
    await load();
  }

  Future<void> deleteReminder(String id) async {
    await repository.delete(id);
    await load();
  }
}
