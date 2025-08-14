part of 'reminder_cubit.dart';

class ReminderState {
  final List<ReminderModel> reminders;
  final bool isLoading;

  const ReminderState({
    required this.reminders,
    required this.isLoading,
  });

  factory ReminderState.initial() => const ReminderState(reminders: [], isLoading: false);

  ReminderState copyWith({
    List<ReminderModel>? reminders,
    bool? isLoading,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
