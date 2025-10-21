// ignore_for_file: depend_on_referenced_packages, unnecessary_import

import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_services/services/purchase_service.dart';
import 'package:fines_plus/backend/fines_server.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/fuel_station_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/registration/data/datasources/iextract_tokens_usecase.dart';
import 'package:fines_plus/features/registration/data/models/flutter_secure_storage.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fines_plus/features/reminders/data/datasources/reminder_remote_data_source.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_model.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_local_data_source.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_remote_data_source.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:fines_plus/core/config/flavor_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/app_config.dart';

class AppInitializer {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late final ReferralCubit referralCubit;
  late final PurchaseCubit purchaseCubit;
  late final RegistrationCubit registrationCubit;
  late final FuelStationCubit fuelStationCubit;
  late final MaintenanceCubit maintenanceCubit;
  late final ScheduleCubit scheduleCubit;
  late final AdditionalOptionsCubit additionalOptionsCubit;
  late final RemoteConfigService remoteConfigService;
  final Map<String, int> _scheduledReminderIds = {};




  
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("Background message: ${message.messageId}");
  }
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

    final finesServer = FinesServer();
    await finesServer.start();
    remoteConfigService = await RemoteConfigService.init();
    debugPrint(
      'Remote Config - remindersEnabled: ${remoteConfigService.isRemindersEnabled}, purchaseEnabled: ${remoteConfigService.isPurchaseEnabled}',
    );
    
    // Checking the application version
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version; // e.g. "1.0.1"
    final requiredVersion = remoteConfigService.minSupportedVersion;

    bool isUpdateRequired = _isVersionLower(currentVersion, requiredVersion);

    if (isUpdateRequired) {
      debugPrint("⚠️ App version $currentVersion is lower than required $requiredVersion");

    }
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Kiev'));

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped! Payload: ${details.payload}');
      },
    );

    if (Platform.isAndroid) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        const String soundFileName = 'notify';
        const channel = AndroidNotificationChannel(
          'reminders_channel',
          'Reminder',
          description: 'Channel for reminders',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(soundFileName),
        );
        await androidImpl.createNotificationChannel(channel);

        final granted = await androidImpl.requestNotificationsPermission();
        debugPrint('Android notifications permission granted: $granted');
      }
    }

    // FCM permissions (iOS)
    await FirebaseMessaging.instance.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      debugPrint(" FCM Registration Token: $token");
    }


    debugPrint('All reminders scheduled');

    // Load config
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'autolux');
    final config = await loadAppConfig(flavor);

    // SharedPrefs
    final prefs = await SharedPreferences.getInstance();
    final storage = FlutterSecureStorage();
    final sharedPrefsManager = SharedPrefsManager(prefs);
    final appLinks = AppLinks();
    final tokensRepository = TokensRepositoryImpl(storage);
    final extractTokensUseCase = ExtractTokensUseCase(tokensRepository);
    final expenseRepository = ExpenseRepository(FirebaseFirestore.instance);

   final carInfoLocalDataSource = CarInfoLocalDataSource(sharedPrefsManager);

    referralCubit = ReferralCubit(appLinks, prefs);
    purchaseCubit = PurchaseCubit(PurchaseService(), enabled: remoteConfigService.isPurchaseEnabled);
    maintenanceCubit = MaintenanceCubit(expenseRepository: expenseRepository, localDataSource: carInfoLocalDataSource);
    fuelStationCubit = FuelStationCubit();

    additionalOptionsCubit = AdditionalOptionsCubit(
      extractTokensUseCase: extractTokensUseCase,
      tokensRepository: tokensRepository,
    );

    scheduleCubit = ScheduleCubit(
      repository: ScheduleRepository(),
      maintenanceCubit: maintenanceCubit,
      pushHelper: PushHelper(FlutterLocalNotificationsPlugin()),
      enabled: remoteConfigService.isRemindersEnabled,
    );

    final registrationCubit = RegistrationCubit(
    
      storage: storage, auth: FirebaseAuth.instance,
    );

    await referralCubit.init();
    final carInfoRepository = CarInfoRepository(CarInfoLocalDataSource(sharedPrefsManager), CarInfoRemoteDataSource());

    final reminderRepository = ReminderRepository(
      localDataSource: ReminderLocalDataSourceImpl(sharedPrefsManager),
      remoteDataSource: ReminderRemoteDataSourceImpl(FirebaseFirestore.instance),
    );

    final pushHelper = PushHelper(flutterLocalNotificationsPlugin);

    final historyRepository = HistoryRepository(FirebaseFirestore.instance);
    return AppInitResult(
      config: config,
      carInfoRepository: carInfoRepository,
      reminderRepository: reminderRepository,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      pushHelper: pushHelper,
      historyRepository: historyRepository,
      referralCubit: referralCubit,
      purchaseCubit: purchaseCubit,
      registrationCubit: registrationCubit,
      fuelStationCubit: fuelStationCubit,
      maintenanceCubit: maintenanceCubit,
      scheduleCubit: scheduleCubit,
      additionalOptionsCubit: additionalOptionsCubit,
      remoteConfigService: remoteConfigService,
      expenseRepository: expenseRepository,
      isUpdateRequired: isUpdateRequired,
    );


    
  }
}

extension ReminderScheduling on AppInitializer {
  Future<void> scheduleReminder(ReminderModel reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersEnabled = prefs.getBool("reminders") ?? true;
    final pushEnabled = prefs.getBool("pushNotifications") ?? true;

    if (!(remindersEnabled && pushEnabled)) {
      debugPrint(" Notifications disabled in settings, skip scheduling");
      return;
    }

    final now = DateTime.now();
    if (reminder.dateTime.isBefore(now)) {
      debugPrint(' Reminder ${reminder.id} time is in the past, skipping.');
      return;
    }

    final notificationId = reminder.id.hashCode;
    _scheduledReminderIds[reminder.id] = notificationId;

    final delay = reminder.dateTime.difference(now);
    debugPrint(' Reminder ${reminder.id} scheduled in $delay');

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
  final HistoryRepository historyRepository;
  final ReferralCubit referralCubit;
  final PurchaseCubit purchaseCubit;
  final RegistrationCubit registrationCubit;
  final FuelStationCubit fuelStationCubit;
  final MaintenanceCubit maintenanceCubit;
  final ScheduleCubit scheduleCubit;
  final AdditionalOptionsCubit additionalOptionsCubit;
  final RemoteConfigService remoteConfigService;
  final ExpenseRepository expenseRepository;
  final bool isUpdateRequired;

  AppInitResult({
    required this.config,
    required this.carInfoRepository,
    required this.reminderRepository,
    required this.flutterLocalNotificationsPlugin,
    required this.pushHelper,
    required this.historyRepository,
    required this.referralCubit,
    required this.purchaseCubit,
    required this.registrationCubit,
    required this.fuelStationCubit,
    required this.maintenanceCubit,
    required this.scheduleCubit,
    required this.additionalOptionsCubit,
    required this.remoteConfigService,
    required this.expenseRepository,
    required this.isUpdateRequired,
  });
}
