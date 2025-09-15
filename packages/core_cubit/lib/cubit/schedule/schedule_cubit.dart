import 'package:bloc/bloc.dart';
import 'package:core_cubit/cubit/schedule/schedule_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/maintenance_repository.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final IMaintenanceRepository repository;

  ScheduleCubit(this.repository) : super(ScheduleState(tasks: []));

  Future<void> loadTasks() async {
    emit(state.copyWith(loading: true));
    final tasks = await repository.getTasks();
    emit(state.copyWith(tasks: tasks, loading: false));
  }

  Future<void> addTask(MaintenanceTask task) async {
    final updatedTasks = List<MaintenanceTask>.from(state.tasks)..add(task);
    emit(state.copyWith(tasks: updatedTasks));
    await repository.saveTasks(updatedTasks);
  }

  Future<void> updateTask(int index, MaintenanceTask task) async {
    final updatedTasks = List<MaintenanceTask>.from(state.tasks);
    updatedTasks[index] = task;
    emit(state.copyWith(tasks: updatedTasks));
    await repository.saveTasks(updatedTasks);
  }

  Future<void> removeTask(int index) async {
    final updatedTasks = List<MaintenanceTask>.from(state.tasks)..removeAt(index);
    emit(state.copyWith(tasks: updatedTasks));
    await repository.saveTasks(updatedTasks);
  }
}
