// ignore_for_file: depend_on_referenced_packages, unnecessary_import

import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/core/extensions/safe_prefs.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/core/services/notification_tap_bus.dart';
import 'package:fines_plus/features/analytics/data/repository/analytics_repository.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/home/data/repositories/tasks_repository.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/maintenance/data/repository/schedule_firebase_repository.dart';
import 'package:fines_plus/features/maintenance/domain/fuel_geofence_monitor.dart';
import 'package:fines_plus/features/maintenance/domain/gas_station_service.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/fuel_station_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/registration/data/datasources/iextract_tokens_usecase.dart';
import 'package:fines_plus/features/registration/data/models/flutter_secure_storage.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository_impl.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_cubit.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_local_data_source.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_remote_data_source.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:fines_plus/core/config/flavor_config.dart';
import 'package:fines_plus/env/env.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/app_config.dart';

class AppInitializer {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late final ReferralCubit referralCubit;
  late final CarInfoCubit carInfoCubit;
  late final PurchaseCubit purchaseCubit;
  late final RegistrationCubit registrationCubit;
  late final FuelStationCubit fuelStationCubit;
  late final MaintenanceCubit maintenanceCubit;
  late final ScheduleCubit scheduleCubit;
  late final StatisticsCubit statisticsCubit;
  late final SubscriptionCubit subscriptionCubit;
  late final CarCubit carCubit;
  late final HistoryCubit historyCubit;
  late final AnalyticsCubit analyticsCubit;
  late final QuickActionsCubit quickActionsCubit;
  late final SettingsCubit settingsCubit;
  late final ReminderCubit reminderCubit;
  late final AdditionalOptionsCubit additionalOptionsCubit;
  late final RemoteConfigService remoteConfigService;
  late final CurrencyService currencyService;
  late final FuelGeofenceMonitor fuelGeofenceMonitor;
  final Map<String, int> _scheduledReminderIds = {};
  late final HistoryRepository historyRepository;
  late final AnalyticsRepository analyticsRepository;
  late final ISubscriptionRepository subscriptionRepository;
  bool _isVersionLower(String current, String required) {
    List<int> parse(String v) => v.split('.').map(int.parse).toList();

    try {
      final c = parse(current);
      final r = parse(required);
      for (int i = 0; i < r.length; i++) {
        if (c[i] < r[i]) return true;
        if (c[i] > r[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint("Version parse error: $e");
      return false;
    }
  }

  Future<AppInitResult> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseCrashlytics.instance.log('AppInit: start');

    remoteConfigService = await RemoteConfigService.init();
    FirebaseCrashlytics.instance.log('AppInit: RemoteConfig done');
    debugPrint(
      'Remote Config - remindersEnabled: ${remoteConfigService.isRemindersEnabled}, purchaseEnabled: ${remoteConfigService.isPurchaseEnabled}',
    );

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final requiredVersion = remoteConfigService.minSupportedVersion;
    bool isUpdateRequired = _isVersionLower(currentVersion, requiredVersion);
    if (isUpdateRequired) {
      debugPrint("App version $currentVersion is lower than required $requiredVersion");
    }

    FirebaseCrashlytics.instance.log('AppInit: timezone');
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Kiev'));

    // Firebase уже инициализирован в main.dart

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    FirebaseCrashlytics.instance.log('AppInit: notifications init');
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped! Payload: ${details.payload}');
        final payload = details.payload;
        if (payload != null && payload.isNotEmpty) {
          NotificationTapBus.emit(payload);
        }
      },
    );
    FirebaseCrashlytics.instance.log('AppInit: notifications done');

    // App was cold-started by tapping a notification — nothing is listening
    // to `NotificationTapBus.stream` yet, so stash it for `MyApp.initState`
    // to pick up once the widget tree (and its router) exists.
    final launchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true && launchPayload != null && launchPayload.isNotEmpty) {
      NotificationTapBus.pendingPayload = launchPayload;
    }

    if (Platform.isAndroid) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        // No custom `sound:` — a channel's sound is locked in at creation
        // time and can't be changed later short of deleting and recreating
        // it, and every reminder notification posted through this channel
        // (delivered via a cold-started BroadcastReceiver when the alarm
        // fires, not the live app) was silently never reaching
        // NotificationManager at all. The default system sound does not
        // have that problem.
        const channel = AndroidNotificationChannel(
          'reminders_channel',
          'Reminder',
          description: 'Channel for reminders',
          importance: Importance.max,
          playSound: true,
        );
        await androidImpl.createNotificationChannel(channel);
        final granted = await androidImpl.requestNotificationsPermission();
        debugPrint('Android notifications permission granted: $granted');

        // Reminders need to fire close to their actual due time — an
        // inexact alarm can be deferred by the OS well past when it was
        // scheduled for (observed: still not delivered a minute after the
        // scheduled time on a fresh Android build). Exact alarms need this
        // separate permission on Android 12+.
        final canScheduleExact = await androidImpl.canScheduleExactNotifications();
        if (canScheduleExact != true) {
          final exactGranted = await androidImpl.requestExactAlarmsPermission();
          debugPrint('Android exact alarms permission granted: $exactGranted');
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    String? fcmToken = prefs.getString('fcm_token');

    if (fcmToken == null) {
      await _initFirebaseMessagingToken(prefs);
    } else {
      debugPrint("Using cached FCM Token: $fcmToken");
    }

    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'autolux');
    final config = await loadAppConfig(flavor);

    final storage = FlutterSecureStorage();
    final sharedPrefsManager = SharedPrefsManager(prefs);
    final appLinks = AppLinks();
    final tokensRepository = TokensRepositoryImpl(storage);
    final firebaseRepository = ScheduleFirebaseRepository(FirebaseFirestore.instance);
    final extractTokensUseCase = ExtractTokensUseCase(tokensRepository);
    final expenseRepository = ExpenseRepository(FirebaseFirestore.instance);
    final historyRepository = HistoryRepository(FirebaseFirestore.instance);
    final analyticsRepository = AnalyticsRepository(firestore: FirebaseFirestore.instance);
    final tasksRepository = TasksRepository(FirebaseFirestore.instance);

    final carInfoLocalDataSource = CarInfoLocalDataSource(
      sharedPrefsManager,
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
    final carInfoRepository = CarInfoRepository(
      carInfoLocalDataSource,
      CarInfoRemoteDataSource(FirebaseFirestore.instance, FirebaseAuth.instance),
    );

    quickActionsCubit = QuickActionsCubit(tasksRepository, prefs);
    currencyService = CurrencyService();
    unawaited(currencyService.init());
    referralCubit = ReferralCubit(appLinks, prefs);

    carCubit = CarCubit(local: carInfoLocalDataSource, repo: carInfoRepository);
    historyCubit = HistoryCubit(repository: historyRepository, carCubit: carCubit);
    analyticsCubit = AnalyticsCubit(repository: analyticsRepository, carCubit: carCubit);
    carInfoCubit = CarInfoCubit(carInfoRepository, historyCubit);
    carCubit.setHistoryCubit(historyCubit);

    maintenanceCubit = MaintenanceCubit(
      expenseRepository: expenseRepository,
      localDataSource: carInfoLocalDataSource,
      carCubit: carCubit,
    );
    fuelStationCubit = FuelStationCubit();
    statisticsCubit = StatisticsCubit(maintenanceCubit);
    settingsCubit = SettingsCubit(currencyService: currencyService);
    FirebaseCrashlytics.instance.log('AppInit: creating SubscriptionRepository');
    subscriptionRepository = SubscriptionRepository(
      InAppPurchase.instance,
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
    FirebaseCrashlytics.instance.log('AppInit: SubscriptionRepository done');

    purchaseCubit = PurchaseCubit(subscriptionRepository, enabled: remoteConfigService.isPurchaseEnabled);
    final subscriptionCubit = SubscriptionCubit( purchaseCubit: purchaseCubit, repository: subscriptionRepository,
    );
    additionalOptionsCubit = AdditionalOptionsCubit(
      extractTokensUseCase: extractTokensUseCase,
      tokensRepository: tokensRepository,
    );

    scheduleCubit = ScheduleCubit(
      repository: ScheduleRepository(),
      maintenanceCubit: maintenanceCubit,
      pushHelper: PushHelper(flutterLocalNotificationsPlugin),
      enabled: remoteConfigService.isRemindersEnabled,
      ownerId: '',
      carNumber: '',
      carCubit: carCubit,
      firebaseRepo: firebaseRepository,
    );

    registrationCubit = RegistrationCubit(storage: storage, auth: FirebaseAuth.instance);

    unawaited(referralCubit.init());

    final reminderRepository = ReminderRepository(
      localDataSource: ReminderLocalDataSourceImpl(sharedPrefsManager),
    );
    final pushHelper = PushHelper(flutterLocalNotificationsPlugin);
    reminderCubit = ReminderCubit(repository: reminderRepository, pushHelper: pushHelper, carNumber: '', ownerId: '');

    // Phase 1 of the "prompt to log a fuel purchase" scenario — foreground/
    // background (not fully-killed-app) geofencing only; see
    // FuelGeofenceMonitor's doc comment for why.
    fuelGeofenceMonitor = FuelGeofenceMonitor(GasStationService(Env.mapApiKey), pushHelper);
    unawaited(fuelGeofenceMonitor.start());

    return AppInitResult(
      config: config,
      carInfoRepository: carInfoRepository,
      reminderRepository: reminderRepository,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      pushHelper: pushHelper,
      historyRepository: historyRepository,
      referralCubit: referralCubit,
      purchaseCubit: purchaseCubit,
      carInfoCubit: carInfoCubit,
      registrationCubit: registrationCubit,
      fuelStationCubit: fuelStationCubit,
      maintenanceCubit: maintenanceCubit,
      statisticsCubit: statisticsCubit,
      reminderCubit: reminderCubit,
      scheduleCubit: scheduleCubit,
      carCubit: carCubit,
      analyticsCubit: analyticsCubit,
      settingsCubit: settingsCubit,
      additionalOptionsCubit: additionalOptionsCubit,
      remoteConfigService: remoteConfigService,
      expenseRepository: expenseRepository,
      isUpdateRequired: isUpdateRequired,
      subscriptionCubit: subscriptionCubit,
      quickActionsCubit: quickActionsCubit,
      subscriptionRepository: subscriptionRepository,
      firebaseRepository: firebaseRepository,
      analyticsRepository: analyticsRepository,
      tasksRepository: tasksRepository,
      currencyService: currencyService,
    );
  }

  Future<void> _initFirebaseMessagingToken(SharedPreferences prefs) async {
    try {
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNS token is not available yet, skipping FCM token init for now');
          return;
        }
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await prefs.setString('fcm_token', token);
        debugPrint('FCM Registration Token: $token');
      }
    } catch (e, st) {
      debugPrint('Failed to get FCM token: $e\n$st');
    }
  }
}

extension ReminderScheduling on AppInitializer {
  Future<void> scheduleReminder(ReminderModel reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersEnabled = prefs.getBoolSafe("reminders", defaultValue: true);
    final pushEnabled = prefs.getBoolSafe("pushNotifications", defaultValue: true);

    if (!(remindersEnabled && pushEnabled)) {
      debugPrint("Notifications disabled in settings, skip scheduling");
      return;
    }

    final now = DateTime.now();
    if (reminder.dateTime.isBefore(now)) {
      debugPrint('Reminder ${reminder.id} time is in the past, skipping.');
      return;
    }

    final notificationId = reminder.id.hashCode;
    _scheduledReminderIds[reminder.id] = notificationId;

    final delay = reminder.dateTime.difference(now);
    debugPrint('Reminder ${reminder.id} scheduled in $delay');

    Future.delayed(delay, () async {
      const String soundFileName = 'notify';
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        reminder.title,
        reminder.description,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminder',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: 'ic_stat_logo',
            sound: RawResourceAndroidNotificationSound(soundFileName),
          ),
        ),
        payload: reminder.id,
      );
      debugPrint('Reminder ${reminder.id} triggered at ${DateTime.now()}');
    });
  }

  Future<void> cancelReminder(String reminderId) async {
    final id = _scheduledReminderIds[reminderId];
    if (id != null) {
      await flutterLocalNotificationsPlugin.cancel(id);
      _scheduledReminderIds.remove(reminderId);
    }
  }
}

class AppInitResult {
  final AppConfig config;
  final CarInfoRepository carInfoRepository;
  final ReminderRepository reminderRepository;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final PushHelper pushHelper;
  final CarInfoCubit carInfoCubit;
  final HistoryRepository historyRepository;
  final ReferralCubit referralCubit;
  final PurchaseCubit purchaseCubit;
  final RegistrationCubit registrationCubit;
  final FuelStationCubit fuelStationCubit;
  final MaintenanceCubit maintenanceCubit;
  final StatisticsCubit statisticsCubit;
  final ScheduleCubit scheduleCubit;
  final CarCubit carCubit;
  final AnalyticsCubit analyticsCubit;
  final SettingsCubit settingsCubit;
  final ReminderCubit reminderCubit;
  final SubscriptionCubit subscriptionCubit;
  final QuickActionsCubit quickActionsCubit;
  final AdditionalOptionsCubit additionalOptionsCubit;
  final RemoteConfigService remoteConfigService;
  final ExpenseRepository expenseRepository;
  final bool isUpdateRequired;
  final ISubscriptionRepository subscriptionRepository;
  final ScheduleFirebaseRepository firebaseRepository;
  final AnalyticsRepository analyticsRepository;
  final TasksRepository tasksRepository;
  final CurrencyService currencyService;

  AppInitResult({
    required this.config,
    required this.carInfoRepository,
    required this.reminderRepository,
    required this.flutterLocalNotificationsPlugin,
    required this.pushHelper,
    required this.carInfoCubit,
    required this.historyRepository,
    required this.referralCubit,
    required this.purchaseCubit,
    required this.registrationCubit,
    required this.fuelStationCubit,
    required this.maintenanceCubit,
    required this.statisticsCubit,
    required this.scheduleCubit,
    required this.carCubit,
    required this.analyticsCubit,
    required this.settingsCubit,
    required this.reminderCubit,
    required this.subscriptionCubit,
    required this.quickActionsCubit,
    required this.additionalOptionsCubit,
    required this.remoteConfigService,
    required this.expenseRepository,
    required this.isUpdateRequired,
    required this.subscriptionRepository,
    required this.firebaseRepository,
    required this.analyticsRepository,
    required this.tasksRepository,
    required this.currencyService,
  });
}
