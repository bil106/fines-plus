import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/maintenance/data/repository/schedule_firebase_repository.dart';
import 'package:fines_plus/features/schedule/presentation/widgets/action_detail_sheet.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/maintenance_card.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';


@RoutePage()
class ScheduleScreen extends StatefulWidget {
  final ScheduleRepository repository;
  final ReminderRepository reminderRepository;
  final PushHelper pushHelper;
  final String carNumber;
  final String userId;

  const ScheduleScreen({
    super.key,
    required this.repository,
    required this.reminderRepository,
    required this.pushHelper,
    required this.carNumber,
    required this.userId,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int getMaxMileage({int? newMileage}) {
    final cubit = context.read<MaintenanceCubit>();
    final allMileages = [
      ...cubit.state.serviceRecords.map((r) => r.mileage),
      ...cubit.state.fuelRecords.map((r) => r.mileage),
      ...cubit.state.tuningRecords.map((r) => r.mileage),
      ...cubit.state.carWashRecords.map((r) => r.mileage),
      if (newMileage != null) newMileage,
    ];
    return allMileages.isEmpty ? 0 : allMileages.reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
       BlocProvider(
          create: (_) {
            final maintenanceCubit = context.read<MaintenanceCubit>();
           
            final carCubit = context.read<CarCubit>();

            final firebaseRepo = ScheduleFirebaseRepository(FirebaseFirestore.instance);

            final scheduleCubit = ScheduleCubit(
              repository: widget.repository,
              firebaseRepo: firebaseRepo,
              maintenanceCubit: maintenanceCubit,
              pushHelper: widget.pushHelper,
              enabled: true,
              userId: widget.userId,
              carNumber: widget.carNumber,
              carCubit: carCubit,
            );

        
            scheduleCubit.loadTasks();

            return scheduleCubit;
          },
        ),
        BlocProvider(
          create: (_) => ReminderCubit(
            repository: widget.reminderRepository,
            pushHelper: widget.pushHelper,
            carNumber: widget.carNumber,
            userId: widget.userId,
            carCubit: context.read<CarCubit>(),
          ),
        ),
      ],
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          final scheduleCubit = context.read<ScheduleCubit>();
          final reminderCubit = context.read<ReminderCubit>();

          return Scaffold(
            backgroundColor: AppColors.grey50,
            appBar: AppBar(backgroundColor: AppColors.grey50),
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
                        priorExecution: task.lastServiceDate != null
                            ? DateFormat('dd.MM.yyyy').format(task.lastServiceDate!)
                            : null,
                        lastMileage: task.lastMileage,
                        actualMileage: getMaxMileage(newMileage: task.lastMileage),
                        intervalKm: task.intervalKm,
                        onPressed: () async {
                          final result = await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => ActionDetailSheet(
                              title: task.title,
                              lastServiceDate: task.lastServiceDate != null
                                  ? DateFormat('dd.MM.yyyy').format(task.lastServiceDate!)
                                  : null,
                              lastMileage: task.lastMileage,
                              actualMileage: getMaxMileage(newMileage: task.lastMileage),
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
                              lastServiceDate: result["date"] as DateTime?, // ✅ DateTime
                              lastMileage: last,
                              actualMileage: actual,
                              intervalKm: result["intervalKm"] ?? task.intervalKm,
                              intervalTime: result["byDate"] ? Duration(days: result["intervalDays"]) : null,
                              comment: result["comment"],
                            );

                            scheduleCubit.updateTask(index, updatedTask, reminderCubit: reminderCubit);
                          }
                        },
                        onDelete: () => scheduleCubit.removeTask(index),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => const ActionDetailSheet(),
                );

                if (result != null) {
                  final last = result["mileage"] ?? 0;
                  final actual = getMaxMileage(newMileage: last);

                  final newTask = MaintenanceTask(
                    title: result["title"] ?? S.of(context).no_name,
                    lastServiceDate: result["date"] as DateTime?, // ✅ DateTime
                    lastMileage: last,
                    actualMileage: actual,
                    intervalKm: result["intervalKm"] ?? 0,
                    intervalTime: result["byDate"] ? Duration(days: result["intervalDays"]) : null,
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




