part of 'reminder_cubit.dart';



class ReminderState {
  final List<ReminderModel> reminders;

  /// [reminders] plus the automatic ones, in display order.
  final List<ReminderItem> items;

  /// The car's schedule tasks, for the Home progress rings.
  final List<MaintenanceTask> tasks;

  final bool isLoading;
  final String? errorMessage;

  ReminderState({
    required this.reminders,
    this.items = const [],
    this.tasks = const [],
    required this.isLoading,
    this.errorMessage,
  });

  ReminderState copyWith({
    List<ReminderModel>? reminders,
    List<ReminderItem>? items,
    List<MaintenanceTask>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      items: items ?? this.items,
      tasks: tasks ?? this.tasks,
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

