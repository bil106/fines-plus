
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';

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
