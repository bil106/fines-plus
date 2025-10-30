// ignore_for_file: unused_element_parameter

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/ad_banner_widget.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/car_wash_record_card.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/delete_expenses_button.dart';
import 'package:fines_plus/features/maintenance/presentation/widgets/fab_menu.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/fuel_record_card.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/service_record_card.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/tuning_record_card.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_remote_data_source.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class MaintenanceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFuelUp;
  final VoidCallback? onService;
  final VoidCallback? onTuning;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;

  const MaintenanceScreen({
    super.key,
    this.onBack,
    this.onCalendar,
    this.onSettings,
    this.onFuelUp,
    this.onService,
    this.onTuning,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
 
@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final maintenanceCubit = context.read<MaintenanceCubit>();
       maintenanceCubit.clearAllRecords();
      await maintenanceCubit.syncExpensesFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MaintenanceScreenView(onBack: widget.onBack, onCalendar: widget.onCalendar, onSettings: widget.onSettings);
  }
}

class _MaintenanceScreenView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;
  final VoidCallback? onFuelUp;
  final VoidCallback? onCarWash;
  final VoidCallback? onService;
  final VoidCallback? onTuning;

  const _MaintenanceScreenView({
    this.onBack,
    this.onCalendar,
    this.onSettings,
    this.onFuelUp,
    this.onService,
    this.onTuning,
    this.onCarWash,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: onBack ?? () {}),
        actions: const [DeleteExpensesButton()],
      ),

      body: BlocBuilder<MaintenanceCubit, MaintenanceState>(
        builder: (context, state) {
          final cubit = context.read<MaintenanceCubit>();

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).tech_service, style: textTheme.title),
                    AppSpacers.verticalMedium,
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          final hasRecords =
                              state.serviceRecords.isNotEmpty ||
                              state.tuningRecords.isNotEmpty ||
                              state.fuelRecords.isNotEmpty ||
                              state.carWashRecords.isNotEmpty;

                          if (!hasRecords) {
                            return Center(
                              child: Text(
                                S.current.no_records,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.grey700),
                              ),
                            );
                          }

                          return ListView(
                            children: [
                              ...state.serviceRecords.map((r) => ServiceRecordCard(record: r)),
                              ...state.tuningRecords.map((r) => TuningRecordCard(record: r)),
                              ...state.fuelRecords.map((r) => FuelRecordCard(record: r)),
                              ...state.carWashRecords.map((r) => CarWashRecordCard(record: r)),
                            ],
                          );
                        },
                      ),
                    ),
                    AppSpacers.verticalLargeXL,
                    const AdBannerWidget(),
                  ],
                ),
              ),
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              if (state.isMenuOpen)
                GestureDetector(
                  onTap: cubit.closeMenu,
                  child: Container(color: AppColors.black.withOpacity(0.4)),
                ),

              FABMenu(
                isMenuOpen: state.isMenuOpen,
                cubit: cubit,
                actions: [
                  FABAction(
                    icon: const Icon(Icons.more_horiz, color: AppColors.energyBlue),
                    onTap: () async {
                      cubit.closeMenu();
                      final prefs = await SharedPreferences.getInstance();
                      final localDataSource = ReminderLocalDataSourceImpl(SharedPrefsManager(prefs));
                      final remoteDataSource = ReminderRemoteDataSourceImpl(FirebaseFirestore.instance);

                      final reminderRepository = ReminderRepository(
                        localDataSource: localDataSource,
                        remoteDataSource: remoteDataSource,
                      );

                      final scheduleRepository = ScheduleRepository();

                      await context.router.push(
                        ScheduleRoute(
                          repository: scheduleRepository,
                          reminderRepository: reminderRepository,
                          pushHelper: PushHelper(FlutterLocalNotificationsPlugin()),
                          carNumber: '', userId: '',
                        ),
                      );
                    },
                  ),
                  FABAction(
                    icon: const Icon(Icons.settings, color: AppColors.energyBlue),
                    onTap: () {
                      cubit.closeMenu();
                      context.findAncestorStateOfType<HomeScreenWrapperState>()?.openPage(HomePage.settings);
                    },
                  ),
                  FABAction(
                    icon: Image.asset('assets/icons/tuning.jpg', color: AppColors.energyBlue, height: 24),
                    onTap: () async {
                      cubit.closeMenu();
                      final records = await context.router.push<List<TuningRecord>>(TuningRoute());
                      if (records != null && records.isNotEmpty) {
                        cubit.addTuningRecordsList(records);
                        onTuning?.call();
                      }
                    },
                  ),
                  FABAction(
                    icon: const Icon(Icons.build, color: AppColors.energyBlue),
                    onTap: () async {
                      cubit.closeMenu();
                      final records = await Navigator.push<List<ServiceRecord>>(
                        context,
                        MaterialPageRoute(builder: (_) => const ServiceScreen()),
                      );
                      if (records != null && records.isNotEmpty) {
                        cubit.addServiceRecords(records);
                        onService?.call();
                      }
                    },
                  ),
                  FABAction(
                    icon: SvgPicture.asset(
                      'assets/icons/car-wash.svg',
                      color: AppColors.energyBlue,
                      colorBlendMode: BlendMode.srcIn,
                      height: 24,
                    ),
                    onTap: () async {
                      cubit.closeMenu();
                      final record = await context.router.push<CarWashRecord>(CarWashRoute());
                      if (record != null) {
                        cubit.addCarWashRecord(record);
                      }
                    },
                  ),
                  FABAction(
                    icon: const Icon(Icons.local_gas_station, color: AppColors.energyBlue),
                    onTap: () async {
                      cubit.closeMenu();
                      final record = await context.router.push<FuelRecord>(FuelUpRoute());
                      if (record != null) {
                        cubit.addFuelRecord(record);
                        onFuelUp?.call();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
