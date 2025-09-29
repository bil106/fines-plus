import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/car_info/car_info_cubit.dart';
import 'package:core_cubit/cubit/history/history_cubit.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_cubit.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_cubit/cubit/schedule/schedule_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/history_repository.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:core_repository/schedule_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/presentation/screens/analytics_screen.dart';
import 'package:fines_plus/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/presentation/screens/car_wash_map_screen.dart';
import 'package:fines_plus/presentation/screens/car_wash_screen.dart';
import 'package:fines_plus/presentation/screens/export_screen.dart';
import 'package:fines_plus/presentation/screens/fine_check_screen.dart';
import 'package:fines_plus/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/presentation/screens/history_screen.dart';
import 'package:fines_plus/presentation/screens/registration_screen.dart';
import 'package:fines_plus/presentation/screens/reminders_screen.dart';
import 'package:fines_plus/presentation/screens/schedule_screen.dart';
import 'package:fines_plus/presentation/screens/service_screen.dart';
import 'package:fines_plus/presentation/screens/settings_screen.dart';
import 'package:fines_plus/presentation/screens/maintenance_screen.dart';
import 'package:fines_plus/presentation/screens/tuning_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomePage {
  addCar,
  fines,
  reminders,
  analytics,
  carInfo,
  fineCheck,
  settings,
  history,
  maintenance,
  export,
  registration,
  fuel,
  service,
  tuning,
  carWash,
  schedule,
}

@RoutePage()
class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => HomeScreenWrapperState();
}

class HomeScreenWrapperState extends State<HomeScreenWrapper> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<EventModel> exportHistory = [];
  String? _carNumber;
  String? _docSeries;
  String? _docNumber;

  late final HistoryCubit historyCubit;
  late final CarInfoCubit carInfoCubit;

  @override
  void initState() {
    super.initState();
    _loadCarNumber();

    historyCubit = HistoryCubit(repository: context.read<HistoryRepository>());
    carInfoCubit = CarInfoCubit(context.read<CarInfoRepository>(), historyCubit);
  }

  Future<void> _loadCarNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _carNumber = prefs.getString('carNumber') ?? '';
      _docSeries = prefs.getString('docSeries') ?? '';
      _docNumber = prefs.getString('docNumber') ?? '';
    });
  }

  void _saveCarInfo(String carNumber, String series, String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carNumber', carNumber);
    await prefs.setString('docSeries', series);
    await prefs.setString('docNumber', number);

    setState(() {
      _carNumber = carNumber;
      _docSeries = series;
      _docNumber = number;
    });
  }

  void openPage(HomePage page) {
    final index = HomePage.values.indexOf(page);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentIndex = index);
    if (page == HomePage.maintenance) {
      context.read<MaintenanceCubit>().closeMenu();
    }
  }

  int get _bottomNavIndex => _currentIndex.clamp(0, 2);

  @override
  void dispose() {
    _pageController.dispose();
    historyCubit.close();
    carInfoCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carNumber == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: historyCubit),
        BlocProvider.value(value: carInfoCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
        
            AddCarScreen(
              key: const ValueKey('add_car_screen'),
              onOpenCarInfo: () => openPage(HomePage.carInfo),
              onFineCheck: () => openPage(HomePage.fineCheck),
              onMaintenance: () => openPage(HomePage.maintenance),
              onAnalytics: () => openPage(HomePage.analytics),
            ),

           FinesScreen(key: const ValueKey('fines_screen'), onBack: () => openPage(HomePage.addCar)),


            RemindersScreen(
              key: const ValueKey('reminders'),
              carNumber: _carNumber!,
              onBack: () => openPage(HomePage.addCar),
            ),

            AnalyticsScreen(
              key: const ValueKey('analytics'),
              carNumber: _carNumber!,
              onBack: () => openPage(HomePage.addCar),
            ),

            CarInfoScreen(
              key: const ValueKey('car_info_screen'),
              initialCarNumber: _carNumber!,
              onBack: () => openPage(HomePage.addCar),
              onCheckFine: (carNumber, series, number) {
                _saveCarInfo(carNumber, series, number);
                openPage(HomePage.history);
              },
            ),

            FineCheckScreen(
              key: const ValueKey('fine_check_screen'),
              carNumber: _carNumber!,
              docSeries: _docSeries ?? '',
              docNumber: _docNumber ?? '',
              onBack: () => openPage(HomePage.addCar),
            ),

         SettingsScreen(
              key: const ValueKey('settings_screen'),
              onBack: () => openPage(HomePage.maintenance),
              remoteConfigService: context.read<RemoteConfigService>(), 
              scheduleCubit: context.read<ScheduleCubit>(), 
              purchaseCubit: context.read<PurchaseCubit>(), 
            ),
            HistoryScreen(key: const ValueKey('history_screen'), carNumber: _carNumber!),

            Builder(
              key: const ValueKey('maintenance_screen'),
              builder: (_) {
                return MaintenanceScreen(
                  onFuelUp: () => openPage(HomePage.fuel),
                  onService: () => openPage(HomePage.service),
                  onTuning: () => openPage(HomePage.tuning),
                  onBack: () => openPage(HomePage.addCar),
                );
              },
            ),
           
            ExportScreen(
              key: const ValueKey('export'),
              history: exportHistory,
              carNumber: _carNumber!,
              onBack: () => openPage(HomePage.analytics),
            ),

            RegistrationScreen(key: const ValueKey('registration'), onBack: () => openPage(HomePage.addCar)),
            FuelUpScreen(key: const ValueKey('fuel'), onBack: () => openPage(HomePage.maintenance)),
            CarWashScreen(key: const ValueKey('car-wash'), onBack: () => openPage(HomePage.maintenance)),
            ServiceScreen(key: const ValueKey('service'), onBack: () => openPage(HomePage.maintenance)),
            TuningScreen(key: const ValueKey('tuning'), onBack: () => openPage(HomePage.maintenance)),
            FuelMapScreen(key: const ValueKey('fuel-map')),
            CarWashMapScreen(key: const ValueKey('car-wash-map')),

            Builder(
              key: const ValueKey('schedule_screen'),

              builder: (context) {
                return FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final prefs = snapshot.data!;
                    final localDataSource = ReminderLocalDataSourceImpl(SharedPrefsManager(prefs));
                    final remoteDataSource = ReminderRemoteDataSourceImpl(FirebaseFirestore.instance);

                    final reminderRepository = ReminderRepository(
                      localDataSource: localDataSource,
                      remoteDataSource: remoteDataSource,
                    );

                    final scheduleRepository = ScheduleRepository();

                    return ScheduleScreen(
                      repository: scheduleRepository,
                      reminderRepository: reminderRepository,
                      pushHelper: PushHelper(FlutterLocalNotificationsPlugin()),
                      carNumber: _carNumber ?? '',
                    );
                  },
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.neutreBlanc,
          currentIndex: _bottomNavIndex,
          onTap: (i) {
            final page = HomePage.values[i];

            if (page == HomePage.fineCheck) {
              openPage(HomePage.fineCheck);
            } else {
              openPage(page);
            }
          },
          selectedIconTheme: IconThemeData(color: AppColors.blue700),
          unselectedItemColor: AppColors.grey700,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: S.of(context).auto),
            BottomNavigationBarItem(icon: Icon(Icons.receipt), label: S.of(context).fines),
            BottomNavigationBarItem(icon: Icon(Icons.support), label: S.of(context).reminder),
          ],
        ),
      ),
    );
  }
}
