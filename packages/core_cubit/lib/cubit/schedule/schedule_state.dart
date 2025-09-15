import 'package:core_data/core_data.dart';

class ScheduleState {
  final List<MaintenanceTask> tasks;
  final bool loading;

  ScheduleState({required this.tasks, this.loading = false});

  ScheduleState copyWith({List<MaintenanceTask>? tasks, bool? loading}) {
    return ScheduleState(
      tasks: tasks ?? this.tasks,
      loading: loading ?? this.loading,
    );
  }
}
