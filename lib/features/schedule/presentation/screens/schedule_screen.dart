import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/home/data/repositories/tasks_repository.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_state.dart';
import 'package:fines_plus/features/home/presentation/widgets/insurance_detail_sheet.dart';
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
import 'package:fines_plus/features/schedule/presentation/widgets/insurance_card.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  ScheduleCubit? scheduleCubit;
  ReminderCubit? reminderCubit;
  late PushHelper pushHelper;
  late ScheduleFirebaseRepository firebaseRepo;

  @override
  void initState() {
    super.initState();

    pushHelper = PushHelper(FlutterLocalNotificationsPlugin());
    firebaseRepo = ScheduleFirebaseRepository(FirebaseFirestore.instance);

    if (widget.carNumber.isNotEmpty) {
      _initCubits(widget.carNumber, widget.userId);
    }

    final carCubit = context.read<CarCubit>();
    carCubit.stream.listen((carState) {
      final newCar = carState.carNumber;
      if (newCar.isNotEmpty && scheduleCubit?.carNumber != newCar) {
        _initCubits(newCar, widget.userId);
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAction();
      final quick = context.read<QuickActionsCubit>();
      final carNumber = widget.carNumber;
      if (carNumber.isNotEmpty) {
        quick.syncActiveCategories(carNumber);
      }
      quick.init();
    });
  }

  void _initCubits(String carNumber, String userId) {
    if (scheduleCubit != null) return;

    scheduleCubit = ScheduleCubit(
      repository: widget.repository,
      firebaseRepo: firebaseRepo,
      maintenanceCubit: context.read<MaintenanceCubit>(),
      pushHelper: pushHelper,
      enabled: true,
      userId: userId,
      carNumber: carNumber,
      carCubit: context.read<CarCubit>(),
    );

    reminderCubit = ReminderCubit(
      repository: widget.reminderRepository,
      carNumber: carNumber,
      userId: userId,
      pushHelper: pushHelper,
    );
  }

  void addEvent(MaintenanceTask task) {
    if (scheduleCubit == null || scheduleCubit!.carNumber.isEmpty) {
      return;
    }

    scheduleCubit!.addTask(task, reminderCubit: reminderCubit);

    context.read<QuickActionsCubit>().activateCategory(task.category);
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

  void _openActionDetailSheet(String description) async {
    final result = await showModalBottomSheet<MaintenanceTask>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ActionDetailSheet(
          description: description,
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

    if (result != null) {
      addEvent(result);
    }
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

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateFormat('dd.MM.yyyy').parse(value);
      } catch (_) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  void _handleQuickActions(QuickActionsState state) {
    if (scheduleCubit == null || reminderCubit == null || scheduleCubit!.carNumber.isEmpty) return;

    final settingsCubit = context.read<SettingsCubit>();
    final unit = settingsCubit.state.unit;

    for (final entry in state.createdTasks.entries) {
      for (final data in entry.value) {
        if (data['deleted'] == true) continue;

        final isInsurance = data['isInsurance'] == true;

        final alreadyExists =
            !isInsurance &&
            scheduleCubit!.state.tasks.any(
              (t) => t.description.toLowerCase() == (data['description']?.toString().toLowerCase() ?? ''),
            );

        if (alreadyExists) continue;

        if (isInsurance && scheduleCubit!.state.tasks.any((t) => t.isInsurance)) {
          continue;
        }

        final lastMileageKm = data["mileage"] ?? 0;
        final intervalKm = data["intervalKm"] ?? 0;
        final intervalKmValue = unit == 'mil' ? (intervalKm / 0.621371).round() : intervalKm;

        final key = entry.key;
        final newTask = MaintenanceTask(
          description: isInsurance
              ? S.of(context).insurance
              : (data['description']?.toString() ?? S.of(context).no_name),
          category: isInsurance ? 'insurance' : (data['category']?.toString().toLowerCase() ?? key),
          lastServiceDate: _parseDate(data['date']),
          lastMileage: lastMileageKm,
          actualMileage: getMaxMileage(newMileage: lastMileageKm),
          intervalKm: intervalKmValue == 0 ? null : intervalKmValue,
          intervalTime: data['byDate'] == true ? Duration(days: data['intervalDays'] ?? 365) : null,
          comment: data['comment']?.toString(),
          isInsurance: isInsurance,
        );

        scheduleCubit!.addTask(newTask, reminderCubit: reminderCubit);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCar = context.watch<CarCubit>().state.carNumber.isNotEmpty;

    if (!hasCar) {
      return Center(child: Text(S.of(context).no_schedule, style: Theme.of(context).textTheme.black16bold));
    }

    if (scheduleCubit == null || reminderCubit == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: scheduleCubit!),
        BlocProvider.value(value: reminderCubit!),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<QuickActionsCubit, QuickActionsState>(
            listener: (context, state) {
              _handleQuickActions(state);
            },
          ),
          BlocListener<ScheduleCubit, ScheduleState>(
            listener: (context, state) async {
              final quick = context.read<QuickActionsCubit>();

              if (!state.loading) {
                final currentCategories = state.tasks.map((t) => t.category.toLowerCase()).toList();
                quick.updateActiveCategoriesFromTasks(currentCategories);
              }

              if (state.tasksRemoved.isNotEmpty) {
                debugPrint(
                  'ScheduleCubit emitted tasksRemoved: ${state.tasksRemoved.map((t) => "${t.id}:${t.category}")}',
                );

                for (var task in state.tasksRemoved) {
                  await quick.onTaskDeleted(task.category);
                  quick.clearCreatedTask(task.category);
                }
                quick.syncWithRepository();
              }
            },
          ),
        ],
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
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];

                          return task.isInsurance
                              ? InsuranceCard(
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
                                          final parsedDate = _parseDate(data['date']);
                                          final updatedTask = task.copyWith(
                                            lastServiceDate: parsedDate,
                                            intervalTime: data['intervalDays'] != null
                                                ? Duration(days: data['intervalDays'])
                                                : null,
                                            comment: data['comment']?.toString(),
                                          );
                                          final index = scheduleCubit!.state.tasks.indexOf(task);
                                          if (index != -1) {
                                            scheduleCubit!.updateTask(index, updatedTask, reminderCubit: reminderCubit);
                                          }
                                        },
                                      ),
                                    );
                                  },
                                  onDelete: () async {
                                    final quick = context.read<QuickActionsCubit>();
                                    final tasksRepository = context.read<TasksRepository>();
                                    final carNumber = context.read<CarCubit>().state.carNumber;
                                    final indexToRemove = scheduleCubit!.state.tasks.indexOf(task);
                                    if (indexToRemove != -1) {
                                      await scheduleCubit!.removeTask(indexToRemove, reminderCubit: reminderCubit);
                                    }
                                    quick.deactivateCategory(task.category.toLowerCase());
                                    unawaited(
                                      tasksRepository.removeTask(task.category.toLowerCase(), carNumber: carNumber),
                                    );
                                  },
                                )
                              : MaintenanceCard(
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
                                      scheduleCubit!.updateTask(index, updatedTask, reminderCubit: reminderCubit);
                                      context.read<QuickActionsCubit>().init();
                                    }
                                  },
                                  onDelete: () async {
                                    final quick = context.read<QuickActionsCubit>();
                                    final tasksRepository = context.read<TasksRepository>();
                                    final labelKey = task.category;

                                    scheduleCubit!.removeTask(index, reminderCubit: reminderCubit);

                                    quick.deactivateCategory(labelKey);

                                    unawaited(
                                      tasksRepository.removeTask(
                                        labelKey,
                                        carNumber: context.read<CarCubit>().state.carNumber,
                                      ),
                                    );
                                  },
                                );
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
