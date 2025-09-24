import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_cubit.dart';
import 'package:core_cubit/cubit/reminder/reminder_cubit.dart';
import 'package:core_cubit/cubit/schedule/schedule_cubit.dart';
import 'package:core_cubit/cubit/schedule/schedule_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:core_repository/schedule_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/core/widgets/action_detail_sheet.dart';
import 'package:fines_plus/core/widgets/maintenance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



@RoutePage()
class ScheduleScreen extends StatefulWidget {
  final ScheduleRepository repository;
  final ReminderRepository reminderRepository;
  final PushHelper pushHelper;
  final String carNumber;

  const ScheduleScreen({
    super.key,
    required this.repository,
    required this.reminderRepository,
    required this.pushHelper,
    required this.carNumber,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int getMaxMileage({int? newMileage}) {
    final cubit = context.read<MaintenanceCubit>();
    final serviceRecords = cubit.state.serviceRecords;
    final fuelRecords = cubit.state.fuelRecords;
    final tuningRecords = cubit.state.tuningRecords;
    final carWashRecords = cubit.state.carWashRecords;

    final allMileages = [
      ...serviceRecords.map((r) => r.mileage),
      ...fuelRecords.map((r) => r.mileage),
      ...tuningRecords.map((r) => r.mileage),
      ...carWashRecords.map((r) => r.mileage),
      if (newMileage != null) newMileage,
    ];

    if (allMileages.isEmpty) return 0;
    return allMileages.reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MaintenanceCubit>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ScheduleCubit(
            repository: widget.repository,
            maintenanceCubit: cubit,
            pushHelper: PushHelper(FlutterLocalNotificationsPlugin()),
          )..loadTasks(),
        ),
        BlocProvider(
          create: (_) => ReminderCubit(
            repository: widget.reminderRepository,
            pushHelper: widget.pushHelper,
            carNumber: widget.carNumber,
          ),
        ),
      ],
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          final scheduleCubit = context.read<ScheduleCubit>();
          final reminderCubit = context.read<ReminderCubit>();

          return Scaffold(
            backgroundColor: AppColors.grey50,
            appBar: AppBar(
              backgroundColor: AppColors.grey50,
              // leading: BackButton(color: AppColors.blue700, onPressed: onBack ?? () {}),
            ),
            body: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.tasks.isEmpty
                    ? Center(child: Text(S.of(context).no_tasks))
                    : ListView.separated(
                        padding: const EdgeInsets.all(1),
                        itemCount: state.tasks.length,
                        separatorBuilder: (_, __) => AppSpacers.verticalMedium,
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];

                          return MaintenanceCard(
                            title: task.title,
                            progress: task.getProgress(),
                            priorExecution: task.lastServiceDate,
                            lastMileage: task.lastMileage,
                            actualMileage: getMaxMileage(
                                newMileage: task.lastMileage),
                            intervalKm: task.intervalKm,
                            onPressed: () async {
                              final result =
                                  await showModalBottomSheet<Map<String, dynamic>>(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (_) => ActionDetailSheet(
                                  title: task.title,
                                  lastServiceDate: task.lastServiceDate,
                                  lastMileage: task.lastMileage,
                                  actualMileage:
                                      getMaxMileage(newMileage: task.lastMileage),
                                  intervalKm: task.intervalKm,
                                  comment: task.comment,
                                  byDate: task.intervalTime != null,
                                  byMileage: task.intervalKm != null,
                                ),
                              );

                              if (result != null) {
                                final last = result["mileage"] ?? task.lastMileage;
                                final actual = getMaxMileage(newMileage: last);

                                final updatedTask = task.copyWith(
                                  title: result["title"],
                                  lastServiceDate: result["date"] != null
                                      ? "${result["date"].day.toString().padLeft(2, '0')}.${result["date"].month.toString().padLeft(2, '0')}.${result["date"].year}"
                                      : null,
                                  lastMileage: last,
                                  actualMileage: actual,
                                  intervalKm:
                                      result["intervalKm"] ?? task.intervalKm,
                                  intervalTime: result["byDate"]
                                      ? Duration(days: result["intervalDays"])
                                      : null,
                                  comment: result["comment"],
                                );

                                scheduleCubit.updateTask(
                                    index, updatedTask,
                                    reminderCubit: reminderCubit);
                              }
                            },
                            onDelete: () => scheduleCubit.removeTask(index),
                          );
                        },
                      ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result =
                    await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => const ActionDetailSheet(),
                );

                if (result != null) {
                  final last = result["mileage"] ?? 0;
                  final actual = getMaxMileage(newMileage: last);

                  final newTask = MaintenanceTask(
                    title: result["title"] ?? S.of(context).no_name,
                    lastServiceDate: result["date"] != null
                        ? "${result["date"].day.toString().padLeft(2, '0')}.${result["date"].month.toString().padLeft(2, '0')}.${result["date"].year}"
                        : null,
                    lastMileage: last,
                    actualMileage: actual,
                    intervalKm: result["intervalKm"] ?? 0,
                    intervalTime: result["byDate"]
                        ? Duration(days: result["intervalDays"])
                        : null,
                    comment: result["comment"],
                  );

                  scheduleCubit.addTask(newTask, reminderCubit: reminderCubit);
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


