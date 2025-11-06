import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/analytics/data/repository/analytics_repository.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/export/presentation/screens/export_screen.dart';
import 'package:fines_plus/features/fines/presentation/screens/fine_check_screen.dart';
import 'package:fines_plus/features/fines/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/screens/history_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_remote_data_source.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_map_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/features/registration/presentation/screens/registration_screen.dart';
import 'package:fines_plus/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/presentation/screens/settings_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/tuning_screen.dart';
import 'package:fines_plus/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  subscription,
  fuelMap,
  carWashMap,
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
  late final AnalyticsCubit analyticsCubit;

  late final Map<HomePage, int> _pageIndexMap;
  DateTime? _lastPressedTime;
  @override
  void initState() {
    super.initState();
    _loadCarNumber();

    historyCubit = HistoryCubit(repository: context.read<HistoryRepository>(), carCubit: context.read<CarCubit>());
    carInfoCubit = CarInfoCubit(context.read<CarInfoRepository>(), historyCubit);
    analyticsCubit = AnalyticsCubit(
      repository: AnalyticsRepository(firestore: FirebaseFirestore.instance),
      carCubit: context.read<CarCubit>(),
    );
    _pageIndexMap = {
      HomePage.addCar: 0,
      HomePage.fines: 1,
      HomePage.reminders: 2,
      HomePage.analytics: 3,
      HomePage.carInfo: 4,
      HomePage.fineCheck: 5,
      HomePage.settings: 6,
      HomePage.history: 7,
      HomePage.maintenance: 8,
      HomePage.export: 9,
      HomePage.registration: 10,
      HomePage.subscription: 11,
      HomePage.fuel: 12,
      HomePage.service: 13,
      HomePage.tuning: 14,
      HomePage.carWash: 15,
      HomePage.schedule: 16,
      HomePage.fuelMap: 17,
      HomePage.carWashMap: 18,
    };
  }

  void refreshUserData() {
    setState(() {});
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
    final index = _pageIndexMap[page] ?? 0;
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
    analyticsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carState = context.watch<CarCubit>().state;
    final carNumber = carState.carNumber;
    if (_carNumber == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          openPage(HomePage.addCar);
          return false;
        }

        final now = DateTime.now();
        if (_lastPressedTime == null || now.difference(_lastPressedTime!) > const Duration(seconds: 2)) {
          _lastPressedTime = now;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).click_again), duration: Duration(seconds: 2)));
          return false;
        }

        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');

        return false;
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: historyCubit),
          BlocProvider.value(value: analyticsCubit),
          BlocProvider(create: (_) => CarInfoCubit(context.read<CarInfoRepository>(), historyCubit)),
        ],
        child: Scaffold(
          backgroundColor: AppColors.grey50,
          body: PageView(
            controller: _pageController,
             physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              AddCarScreen(
                key: const ValueKey('add_car_screen'),
                onOpenCarInfo: () => openPage(HomePage.carInfo),
                onFineCheck: () => openPage(HomePage.fines),
                onMaintenance: () => openPage(HomePage.maintenance),
                onAnalytics: () => openPage(HomePage.analytics),
              ),
              FinesScreen(key: const ValueKey('fines_screen'), onBack: () => openPage(HomePage.addCar)),
              RemindersScreen(
                key: const ValueKey('reminders'),
                carNumber: _carNumber!,
                onBack: () => openPage(HomePage.addCar),
                userId: '',
              ),
            AnalyticsScreen(
                key: const ValueKey('analytics'),
                carNumber: carNumber,
                onBack: () => openPage(HomePage.addCar),
              ),


              BlocProvider(
                create: (_) => ExpensesCubit(repository: ExpenseRepository(FirebaseFirestore.instance)),
                child: CarInfoScreen(
                  key: const ValueKey('car_info_screen'),
               
                  onBack: () => openPage(HomePage.addCar),
                  onCheckFine: (carNumber, series, number) {
                    _saveCarInfo(carNumber, series, number);
                    openPage(HomePage.history);
                  },
              
                ),
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
              HistoryScreen(key: const ValueKey('history_screen'), carNumber: carNumber),
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
              BlocProvider(
                create: (_) => RegistrationCubit(auth: FirebaseAuth.instance, storage: const FlutterSecureStorage()),
                child: RegistrationScreen(key: const ValueKey('registration'), onBack: () => openPage(HomePage.addCar)),
              ),

              SubscriptionScreen(
                key: const ValueKey('subscription'), debugMode: true,

                //  onBack: () => openPage(HomePage.addCar)
              ),
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
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
                        carNumber: carNumber,
                        userId: '',
                      );
                    },
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppColors.energyBlue50,
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
      ),
    );
  }
}
