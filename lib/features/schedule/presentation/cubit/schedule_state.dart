
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';

class ScheduleState {
  final List<MaintenanceTask> tasks;
  final bool loading;
  final List<MaintenanceTask> tasksRemoved; 

  ScheduleState({required this.tasks, this.loading = false, this.tasksRemoved = const []});

  ScheduleState copyWith({List<MaintenanceTask>? tasks, bool? loading, List<MaintenanceTask>? tasksRemoved}) {
    return ScheduleState(
      tasks: tasks ?? this.tasks,
      loading: loading ?? this.loading,
      tasksRemoved: tasksRemoved ?? this.tasksRemoved,
    );
  }
}
