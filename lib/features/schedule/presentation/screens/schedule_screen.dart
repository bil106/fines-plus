import 'package:auto_route/auto_route.dart';

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_detail_sheet.dart';
import 'package:fines_plus/features/schedule/presentation/widgets/action_detail_sheet.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/maintenance_card.dart';
import 'package:fines_plus/features/maintenance/data/models/maintenance_task.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:fines_plus/features/schedule/presentation/widgets/insurance_card.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
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
  final String? initialActionKey;

  const ScheduleScreen({
    super.key,
    required this.repository,
    required this.reminderRepository,
    required this.pushHelper,
    required this.carNumber,
    required this.userId,
    this.initialActionKey,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAction();
      context.read<QuickActionsCubit>().init();
    });
  }

  Future<void> _checkInitialAction() async {
    final key = widget.initialActionKey;
    if (key == null) return;

    final maintenanceCubit = context.read<MaintenanceCubit>();
    ServiceRecord? matchingTask;
    try {
      matchingTask = maintenanceCubit.state.serviceRecords.firstWhere(
        (r) => r.serviceName.toLowerCase() == key.toLowerCase(),
      );
    } catch (_) {
      matchingTask = null;
    }

    if (matchingTask == null) {
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).attention),
          content: Text(S.of(context).no_such_service),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(S.of(context).cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(S.of(context).create)),
          ],
        ),
      );

      if (shouldCreate == true && mounted) {
        _openActionDetailSheet(key);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${matchingTask.serviceName} ${S.of(context).already_planned}")));
    }
  }

  void _openActionDetailSheet(String key) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ActionDetailSheet(
          description: key,
          lastServiceDate: null,
          lastMileage: 0,
          actualMileage: 0,
          intervalKm: 10000,
          comment: '',
          byDate: false,
          byMileage: true,
        ),
      ),
    );
  }

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
    final scheduleCubit = context.read<ScheduleCubit>();
    final reminderCubit = context.read<ReminderCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: scheduleCubit),
        BlocProvider.value(value: reminderCubit),
      ],
      child: BlocListener<QuickActionsCubit, QuickActionsState>(
        listener: (context, state) {
          final scheduleCubit = context.read<ScheduleCubit>();
          final reminderCubit = context.read<ReminderCubit>();
          final settingsCubit = context.read<SettingsCubit>();
          final unit = settingsCubit.state.unit;

          for (final data in state.createdTasks.values) {
            final alreadyExists = scheduleCubit.state.tasks.any(
              (t) => t.description.toLowerCase() == ((data['description'] ?? '').toString().toLowerCase()),
            );

            if (alreadyExists) continue;

            final isInsurance = data['isInsurance'] == true;

            final lastMileageKm = data["mileage"] ?? 0;
            final intervalKm = data["intervalKm"] ?? 0;
            final intervalKmValue = unit == 'mil' ? (intervalKm / 0.621371).round() : intervalKm;

            final selectedDate = data['date'] as DateTime?;

            final newTask = MaintenanceTask(
              description: isInsurance
                  ? S.of(context).insurance
                  : (data['description']?.toString() ?? S.of(context).no_name),
              category: isInsurance ? S.of(context).insurance : (data['category']?.toString() ?? S.of(context).other),
              lastServiceDate: selectedDate,
              lastMileage: lastMileageKm,
              actualMileage: getMaxMileage(newMileage: lastMileageKm),
              intervalKm: intervalKmValue == 0 ? null : intervalKmValue,
              intervalTime: data['byDate'] == true ? Duration(days: data['intervalDays'] ?? 365) : null,
              comment: data['comment']?.toString(),
              isInsurance: isInsurance,
            );

            scheduleCubit.addTask(newTask, reminderCubit: reminderCubit);
          }
        },
        child: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            return Stack(
              children: [
                state.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.tasks.isEmpty
                    ? Center(child: Text(S.of(context).no_tasks))
                    : ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.tasks.length,
                        separatorBuilder: (_, __) => AppSpacers.verticalMedium,
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];

                          if (task.isInsurance) {
                            return InsuranceCard(
                              progress: task.getProgress(),
                              priorExecution: task.lastServiceDate != null
                                  ? DateFormat('dd.MM.yyyy').format(task.lastServiceDate!)
                                  : null,

                              intervalTime: task.intervalTime,
                              onPressed: () async {
                                await showModalBottomSheet<Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => InsuranceDetailSheet(
                                    comment: task.comment,
                                    onSave: (data) {
                                      final updatedTask = task.copyWith(
                                        description: data["description"]?.toString() ?? task.description,
                                        lastServiceDate: data["date"] as DateTime?,
                                        intervalTime: data["byDate"] == true
                                            ? Duration(days: data["intervalDays"] ?? 0)
                                            : null,
                                        comment: data["comment"]?.toString(),
                                      );

                                      scheduleCubit.updateTask(index, updatedTask, reminderCubit: reminderCubit);
                                    },
                                  ),
                                );
                              },
                              onDelete: () {
                                scheduleCubit.removeTask(index, reminderCubit: reminderCubit);
                              },
                            );
                          } else {
                            return MaintenanceCard(
                              description: task.description,
                              category: task.category,
                              progress: task.getProgress(),
                              priorExecution: task.lastServiceDate != null
                                  ? DateFormat('dd.MM.yyyy').format(task.lastServiceDate!)
                                  : null,
                              lastMileage: task.lastMileage,
                              actualMileage: getMaxMileage(newMileage: task.lastMileage),
                              intervalKm: task.intervalKm,
                              intervalTime: task.intervalTime,
                              onPressed: () async {
                                final result = await showModalBottomSheet<Map<String, dynamic>>(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (_) => ActionDetailSheet(
                                    description: task.description,
                                    category: task.category,
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
                                  final updatedTask = task.copyWith(
                                    description: result["description"],
                                    category: result["category"],
                                    lastServiceDate: result["date"] as DateTime?,
                                    lastMileage: result["mileage"] ?? task.lastMileage,
                                    actualMileage: getMaxMileage(newMileage: result["mileage"] ?? task.lastMileage),
                                    intervalKm: result["intervalKm"] ?? task.intervalKm,
                                    intervalTime: result["byDate"] == true
                                        ? Duration(days: (result["intervalDays"] ?? 0))
                                        : null,
                                    comment: result["comment"],
                                  );

                                  scheduleCubit.updateTask(index, updatedTask, reminderCubit: reminderCubit);
                                  context.read<QuickActionsCubit>().init();
                                }
                              },
                              onDelete: () {
                                scheduleCubit.removeTask(index, reminderCubit: reminderCubit);
                                context.read<QuickActionsCubit>().onTaskDeleted(task.category);
                              },
                            );
                          }
                        },
                      ),
                Positioned(
                  bottom: 8,
                  right: 4,
                  child: FloatingActionButton(
                    onPressed: () async {
                      await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => InsuranceDetailSheet(
                          onSave: (data) {
                            final newTask = MaintenanceTask(
                              description: data["description"]?.toString() ?? S.of(context).insurance,
                              category: S.of(context).insurance,
                              lastServiceDate: data["date"] as DateTime?,
                              lastMileage: 0,
                              actualMileage: 0,
                              intervalKm: 0,
                              intervalTime: data["byDate"] == true ? Duration(days: data["intervalDays"] ?? 0) : null,
                              comment: data["comment"]?.toString(),
                              isInsurance: true,
                            );

                            scheduleCubit.addTask(newTask, reminderCubit: reminderCubit);
                          },
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
