import 'package:core_cubit/cubit/schedule/schedule_cubit.dart';
import 'package:core_cubit/cubit/schedule/schedule_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/maintenance_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/core/widgets/action_detail_sheet.dart';
import 'package:fines_plus/core/widgets/maintenance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ScheduleTab extends StatefulWidget {
  final IMaintenanceRepository repository;

  const ScheduleTab({super.key, required this.repository});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  late final ScheduleCubit scheduleCubit;

  @override
  void initState() {
    super.initState();
    scheduleCubit = ScheduleCubit(widget.repository)..loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(context.read<IMaintenanceRepository>())..loadTasks(),
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());
          if (state.tasks.isEmpty) return Center(child: Text(S.of(context).no_tasks));

          return Scaffold(
            backgroundColor: AppColors.grey50,
            body: ListView.separated(
              padding: const EdgeInsets.all(1),
              itemCount: state.tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return MaintenanceCard(
                  title: task.title,
                  progress: task.getProgress(),
                  priorExecution: task.lastServiceDate,
                  lastMileage: task.lastMileage,
                  actualMileage: task.actualMileage,
                  intervalKm: task.intervalKm,
                  onPressed: () async {
                    final result = await showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => ActionDetailSheet(
                        title: task.title,
                        lastServiceDate: task.lastServiceDate,
                        lastMileage: task.lastMileage,
                        actualMileage: task.actualMileage,
                        intervalKm: task.intervalKm,
                        comment: task.comment,
                        byDate: task.intervalTime != null,
                        byMileage: task.intervalKm != null,
                      ),
                    );

                    if (result != null) {
                      final updatedTask = task.copyWith(
                        title: result["title"],
                        lastServiceDate: result["date"] != null
                            ? "${result["date"].day.toString().padLeft(2, '0')}.${result["date"].month.toString().padLeft(2, '0')}.${result["date"].year}"
                            : null,
                        lastMileage: result["mileage"],
                        actualMileage: result["mileage"],
                        intervalTime: result["byDate"] ? Duration(days: result["intervalDays"]) : null,
                        comment: result["comment"],
                      );
                      context.read<ScheduleCubit>().updateTask(index, updatedTask);
                    }
                  },
                  onDelete: () => context.read<ScheduleCubit>().removeTask(index),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => const ActionDetailSheet(),
                );

                if (result != null) {
                  final newTask = MaintenanceTask(
                    title: result["title"] ?? S.of(context).no_name,
                    lastServiceDate: result["date"] != null
                        ? "${result["date"].day.toString().padLeft(2, '0')}.${result["date"].month.toString().padLeft(2, '0')}.${result["date"].year}"
                        : null,
                    lastMileage: result["mileage"],
                    actualMileage: result["mileage"],
                    intervalKm: result["byMileage"] ? result["intervalKm"] ?? 0 : 0,
                    intervalTime: result["byDate"] ? Duration(days: result["intervalDays"]) : null,
                    comment: result["comment"],
                  );
                  context.read<ScheduleCubit>().addTask(newTask);
                }
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
