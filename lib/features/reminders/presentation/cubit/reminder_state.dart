part of 'reminder_cubit.dart';



class ReminderState {
  final List<ReminderModel> reminders;
  final bool isLoading;
  final String? errorMessage;

  ReminderState({
    required this.reminders,
    required this.isLoading,
    this.errorMessage,
  });

  ReminderState copyWith({
    List<ReminderModel>? reminders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  
  factory ReminderState.initial() {
    return ReminderState(
      reminders: [],
      isLoading: false,
      errorMessage: null,
    );
  }
}

