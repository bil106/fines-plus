// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/analytics/data/repository/analytics_repository.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/export/presentation/screens/export_screen.dart';

import 'package:fines_plus/features/fines/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/screens/history_screen.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/screens/home_screen.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_remote_data_source.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/features/vehicle/presentation/screens/garage_screen.dart';
import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_map_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/features/registration/presentation/screens/registration_screen.dart';
import 'package:fines_plus/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/features/settings/presentation/screens/settings_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/tuning_screen.dart';
import 'package:fines_plus/features/subscription/presentation/screens/subscription_screen.dart';
import 'dart:io';

import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/env/env.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomePage {
  home,
  addCar,
  fines,
  reminders,
  analytics,
  carInfo,
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
  garage,
}

@RoutePage()
class HomeScreenWrapper extends StatefulWidget {
  final HomePage initialPage;
  const HomeScreenWrapper({super.key, this.initialPage = HomePage.home});

  @override
  State<HomeScreenWrapper> createState() => HomeScreenWrapperState();
}

class HomeScreenWrapperState extends State<HomeScreenWrapper> {
  late final PageController _pageController;
  late int _currentIndex;
  List<EventModel> exportHistory = [];
  String? _carNumber;
  String? _docSeries;
  String? _docNumber;
  int _analyticsTabIndex = 0;
  late final HistoryCubit historyCubit;
  late final CarInfoCubit carInfoCubit;
  late final AnalyticsCubit analyticsCubit;
  late final GarageCubit garageCubit;

  late final Map<HomePage, int> _pageIndexMap;
  DateTime? _lastPressedTime;
  @override
  void initState() {
    super.initState();

    _pageIndexMap = {
      HomePage.home: 0,
      HomePage.addCar: 1,
      HomePage.carInfo: 2,

      HomePage.fines: 3,
      HomePage.reminders: 4,

      HomePage.analytics: 5,
      HomePage.settings: 6,
      HomePage.history: 7,
      HomePage.maintenance: 8,
      HomePage.export: 9,
      HomePage.registration: 10,
      HomePage.subscription: 11,
      HomePage.carWash: 12,
      HomePage.tuning: 13,
      HomePage.fuel: 14,
      HomePage.service: 15,
      HomePage.schedule: 16,
      HomePage.fuelMap: 17,
      HomePage.carWashMap: 18,
      HomePage.garage: 19,
    };

    _currentIndex = _pageIndexMap[HomePage.home]!;
    debugPrint('HomeScreenWrapper: initial computed _currentIndex = $_currentIndex');
    _pageController = PageController(initialPage: _currentIndex);

    debugPrint('HomeScreenWrapper: widget.initialPage = ${widget.initialPage}');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;

      // A missing car number is a valid state here (e.g. right after
      // subscribing during onboarding) — HomeScreen already handles it by
      // prompting the user to add a car. Only an unauthenticated user needs
      // to be bounced back to onboarding.
      if (!kDebugMode && user == null) {
        context.router.replaceAll([const OnboardingRoute()]);
        return;
      }

      _loadCarNumber();
    });

    historyCubit = HistoryCubit(repository: context.read<HistoryRepository>(), carCubit: context.read<CarCubit>());
    carInfoCubit = CarInfoCubit(context.read<CarInfoRepository>(), historyCubit);
    analyticsCubit = AnalyticsCubit(
      repository: AnalyticsRepository(firestore: FirebaseFirestore.instance),
      carCubit: context.read<CarCubit>(),
    );
    garageCubit = GarageCubit(repository: context.read<CarInfoRepository>(), carCubit: context.read<CarCubit>());
  }

  void refreshUserData() {
    setState(() {});
  }

  Future<void> _loadCarNumber() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // Guarantees a car id exists (creating a default, plate-less one if this
    // is a fresh account) before we compute hasCar/gating below.
    await context.read<CarCubit>().ensureCarId();
    if (!mounted) return;

    setState(() {
      _carNumber = prefs.getString('carNumber') ?? '';
      _docSeries = prefs.getString('docSeries') ?? '';
      _docNumber = prefs.getString('docNumber') ?? '';
    });

    final hasSubscription = (kDebugMode || Env.iosBypassSubscription || Platform.isIOS) ? true : await context.read<RegistrationCubit>().checkSubscription();
    if (!mounted) return;

    // Only the "subscription required" case needs to force a page change —
    // jumping to home unconditionally here raced with the user's own
    // navigation (e.g. tapping the settings gear right after launch, before
    // this async check resolved) and snapped them back to Home mid-tap.
    if (!hasSubscription) {
      final index = _pageIndexMap[HomePage.subscription]!;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
      setState(() => _currentIndex = index);
    }
  }

  void _saveCarInfo(String carNumber, String series, String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carNumber', carNumber);
    await prefs.setString('docSeries', series);
    await prefs.setString('docNumber', number);
    if (!mounted) return;
    setState(() {
      _carNumber = carNumber;
      _docSeries = series;
      _docNumber = number;
    });
  }

  void openPage(HomePage page) {
    // Defense in depth: even if some call site still targets the Fines
    // page directly (bypassing the bottom-nav gating below), don't let a
    // brand/market without the feature navigate there.
    if (page == HomePage.fines && !context.read<AppConfig>().finesCheckEnabled) {
      debugPrint("Fines check disabled for this brand - ignoring navigation to HomePage.fines");
      return;
    }

    final carState = context.read<CarCubit>().state;
    final bool hasCar = carState.carId.isNotEmpty;

    final index = _pageIndexMap[page] ?? 0;

    if (page == HomePage.analytics) {
      _analyticsTabIndex = 0;
    }

    if (!kDebugMode && !hasCar && index > 4) {
      debugPrint("Add a car to open this page");
      return;
    }

    // These 20 pages aren't an ordered strip — they're arbitrary, unrelated
    // app screens sharing one PageView as a navigation stack. animateToPage
    // scrolls linearly through every index in between on its way to the
    // target, which visibly flashes through unrelated screens (e.g. Home ->
    // Settings flipped through Fines and Statistics). jumpToPage cuts
    // straight there instead.
    _pageController.jumpToPage(index);

    setState(() => _currentIndex = index);
  }

  void openAnalyticsTab(int tabIndex) {
    _analyticsTabIndex = tabIndex;
    final index = _pageIndexMap[HomePage.analytics]!;
    _pageController.jumpToPage(index);
    setState(() => _currentIndex = index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    historyCubit.close();
    carInfoCubit.close();
    analyticsCubit.close();
    garageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carState = context.watch<CarCubit>().state;
    final carNumber = carState.carNumber;
    final carId = carState.carId;
    final bool hasCar = carState.carId.isNotEmpty;
    final finesCheckEnabled = context.watch<AppConfig>().finesCheckEnabled;
    // Ukraine-only feature (talks to a UA government portal) - hidden from
    // the bottom nav entirely for brands/markets that don't have it.
    final navPages = <HomePage>[
      HomePage.home,
      if (finesCheckEnabled) HomePage.fines,
      HomePage.reminders,
    ];
    if (_carNumber == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != _pageIndexMap[HomePage.home]) {
          openPage(HomePage.home);
          return false;
        }

        final now = DateTime.now();
        if (_lastPressedTime == null || now.difference(_lastPressedTime!) > const Duration(seconds: 2)) {
          _lastPressedTime = now;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).click_again), duration: const Duration(seconds: 2)));
          return false;
        }

        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: historyCubit),
          BlocProvider.value(value: analyticsCubit),
          BlocProvider.value(value: garageCubit),
          BlocProvider(create: (_) => CarInfoCubit(context.read<CarInfoRepository>(), historyCubit)),
        ],
        child: Scaffold(
          backgroundColor: AppColors.grey50,
          body: PageView(
            controller: _pageController,
            physics: (kDebugMode || hasCar) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),

            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              BlocProvider.value(
                value: context.read<QuickActionsCubit>(),
                child: HomeScreen(key: const ValueKey('home')),
              ),
              AddCarScreen(
                key: const ValueKey('add_car_screen'),
                onOpenCarInfo: () => openPage(HomePage.carInfo),
                onFineCheck: () => openPage(HomePage.fines),
                onMaintenance: () => openPage(HomePage.maintenance),
                onAnalytics: () => openPage(HomePage.analytics),
              ),
              BlocProvider(
                create: (_) => ExpensesCubit(repository: ExpenseRepository(FirebaseFirestore.instance)),
                child: CarInfoScreen(
                  key: const ValueKey('car_info_screen'),
                  onBack: () => openPage(HomePage.home),
                  onCheckFine: (carNumber, series, number) {
                    _saveCarInfo(carNumber, series, number);
                    openPage(HomePage.history);
                  },
                ),
              ),

              FinesScreen(key: const ValueKey('fines_screen'), onBack: () => openPage(HomePage.home)),
              BlocProvider(
                key: ValueKey(carNumber),
                create: (_) {
                  final cubit = ReminderCubit(
                    repository: context.read<ReminderRepository>(),
                    carNumber: carId,
                    ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    pushHelper: context.read<PushHelper>(),
                  );

                  cubit.load();
                  return cubit;
                },
                child: RemindersScreen(
                  key: ValueKey('reminders_$carNumber'),
                  ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
              ),

              if (hasCar) ...[
                BlocProvider.value(
                  value: analyticsCubit,
                  child: AnalyticsScreen(
                    key: const ValueKey('analytics'),
                    carNumber: carNumber,
                    onBack: () => openPage(HomePage.home),
                    initialTabIndex: _analyticsTabIndex,
                  ),
                ),

                SettingsScreen(
                  key: const ValueKey('settings_screen'),
                  onBack: () => openPage(HomePage.home),
                ),
                HistoryScreen(key: const ValueKey('history_screen'), carNumber: carNumber),
                Builder(
                  key: const ValueKey('maintenance_screen'),
                  builder: (_) {
                    return MaintenanceScreen(
                      onFuelUp: () => openPage(HomePage.fuel),
                      onService: () => openPage(HomePage.service),
                      onTuning: () => openPage(HomePage.tuning),
                      onBack: () => openPage(HomePage.home),
                    );
                  },
                ),
                ExportScreen(
                  key: const ValueKey('export'),
                  history: exportHistory,
                  carNumber: _carNumber!,
                  onBack: () => openPage(HomePage.analytics),
                ),
                MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: context.read<RegistrationCubit>()),
                    BlocProvider.value(value: context.read<SubscriptionCubit>()),
                  ],
                  child: RegistrationScreen(key: const ValueKey('registration'), onBack: () => openPage(HomePage.home)),
                ),

                BlocProvider.value(
                  value: context.read<SubscriptionCubit>(),
                  child: SubscriptionScreen(
                    onBack: () async {
                      final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                      if (wrapperState != null) {
                        wrapperState.openPage(HomePage.home);
                        return;
                      }
                      context.router.root.replaceAll([HomeRouteWrapper(initialPage: HomePage.home)]);
                    },
                    onPurchaseSuccess: () {
                      final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                      if (wrapperState != null) {
                        wrapperState.openPage(HomePage.garage);
                        return;
                      }
                      context.router.root.replaceAll([HomeRouteWrapper(initialPage: HomePage.garage)]);
                    },
                  ),
                ),

                TuningScreen(key: const ValueKey('tuning'), onBack: () => openPage(HomePage.maintenance)),
                ServiceScreen(key: const ValueKey('service'), onBack: () => openPage(HomePage.maintenance)),
                CarWashScreen(key: const ValueKey('car-wash'), onBack: () => openPage(HomePage.maintenance)),
                FuelUpScreen(key: const ValueKey('fuel'), onBack: () => openPage(HomePage.maintenance)),

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
                          carNumber: carId,
                          ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        );
                      },
                    );
                  },
                ),
                FuelMapScreen(key: const ValueKey('fuel-map')),
                CarWashMapScreen(key: const ValueKey('car-wash-map')),
                GarageScreen(key: const ValueKey('garage_screen'), onBack: () => openPage(HomePage.home), onContinue: () => openPage(HomePage.home)),
              ],
            ],
          ),
          bottomNavigationBar: _isMainTab(_currentIndex)
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutreBlanc,
                    border: Border(top: BorderSide(color: context.brandTheme.surfaceBorder)),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: AppColors.neutreBlanc,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _bottomNavIndexFor(_currentIndex, navPages),
                    onTap: (i) => openPage(navPages[i]),
                    items: [
                      for (final page in navPages)
                        BottomNavigationBarItem(icon: Icon(_navIcon(page)), label: _navLabel(context, page)),
                    ],
                  ),
                )
              : null,

        ),
      ),
    );
  }

  bool _isMainTab(int index) {
    return index == _pageIndexMap[HomePage.home] ||
        index == _pageIndexMap[HomePage.fines] ||
        index == _pageIndexMap[HomePage.reminders] ||
        index == _pageIndexMap[HomePage.addCar] ||
        index == _pageIndexMap[HomePage.analytics] ||
        index == _pageIndexMap[HomePage.schedule] ||
        index == _pageIndexMap[HomePage.maintenance] ||
        index == _pageIndexMap[HomePage.tuning] ||
        index == _pageIndexMap[HomePage.service] ||
        index == _pageIndexMap[HomePage.carWash] ||
        index == _pageIndexMap[HomePage.fuel] ||
        index == _pageIndexMap[HomePage.settings];
  }

  int _bottomNavIndexFor(int pageIndex, List<HomePage> navPages) {
    for (var i = 0; i < navPages.length; i++) {
      if (_pageIndexMap[navPages[i]] == pageIndex) return i;
    }
    return 0;
  }

  IconData _navIcon(HomePage page) {
    switch (page) {
      case HomePage.fines:
        return Icons.confirmation_number_outlined;
      case HomePage.reminders:
        return Icons.access_time;
      case HomePage.home:
      default:
        return Icons.home;
    }
  }

  String _navLabel(BuildContext context, HomePage page) {
    switch (page) {
      case HomePage.fines:
        return S.of(context).fines;
      case HomePage.reminders:
        return S.of(context).reminder;
      case HomePage.home:
      default:
        return S.of(context).home;
    }
  }
}
