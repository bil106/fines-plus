import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:fines_plus/app/app.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_cubit.dart';
import '../env/env.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/export/data/repository/injector.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/maintenance/data/repository/maintenance_repository.dart';
import 'package:fines_plus/features/maintenance/data/repository/schedule_firebase_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/fuel_station_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/reminders/presentation/cubit/reminder_cubit.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/settings/domain/services/settings_service.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_info_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fines_plus/core/services/app_initializer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

late final AppInitializer appInitializer;

FirebaseOptions? _firebaseOptionsForCurrentPlatform() {
  if (!Platform.isIOS) return null;

  return const FirebaseOptions(
    apiKey: 'AIzaSyCLEFL1aB9wi6a1dAhgeUIfVlxoCPPBxrw',
    appId: '1:201100655892:ios:08338a73e5b31708509601',
    messagingSenderId: '201100655892',
    projectId: 'finesplus',
    storageBucket: 'finesplus.firebasestorage.app',
    iosBundleId: 'com.igorbeloded.finesplus',
    iosClientId: '201100655892-2ansipskidg5tdeti65m0oovp2c65l8q.apps.googleusercontent.com',
    androidClientId: '201100655892-250mb0hhicdo25lkmfhdjurka4hv1tqi.apps.googleusercontent.com',
  );
}

void _reportStartupError(Object error, StackTrace stack) {
  debugPrint('STARTUP ERROR: $error');
  debugPrintStack(stackTrace: stack);

  if (Firebase.apps.isNotEmpty) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    if (kDebugMode) {
      debugPrint("BG Message: ${message.messageId}");
    }
  } catch (e, s) {
    _reportStartupError(e, s);
  }
}

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await dotenv.load(fileName: 'assets/config/.env', isOptional: true);

      final firebaseOptions = _firebaseOptionsForCurrentPlatform();
      if (firebaseOptions == null) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: firebaseOptions);
      }
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.log('INIT: Firebase initialized');
      }

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _reportStartupError(error, stack);
        return true;
      };

      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.log('INIT: Starting MobileAds');
      }
      RequestConfiguration configuration = RequestConfiguration(testDeviceIds: Env.testDeviceIdList);
      MobileAds.instance.updateRequestConfiguration(configuration);
      await MobileAds.instance.initialize();
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.log('INIT: MobileAds done');
      }

      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.log('INIT: Starting AppInitializer');
      }
      appInitializer = AppInitializer();
      final result = await appInitializer.init();
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.log('INIT: AppInitializer done');
      }

      await SettingsService.instance.init();
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.log('INIT: SettingsService done');
      }

      final firestore = FirebaseFirestore.instance;
      final repository = SharedPrefsMaintenanceRepository(await SharedPreferences.getInstance());
      final firebaseRepository = ScheduleFirebaseRepository(firestore);
      setupLocator();
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.log('INIT: Starting runApp');
      }

      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: result.carInfoRepository),
            RepositoryProvider.value(value: result.reminderRepository),
            RepositoryProvider.value(value: result.pushHelper),
            RepositoryProvider.value(value: result.historyRepository),
            RepositoryProvider.value(value: result.firebaseRepository),
            RepositoryProvider.value(value: result.tasksRepository),
            RepositoryProvider<IMaintenanceRepository>.value(value: repository),
            RepositoryProvider<ScheduleRepository>(create: (_) => ScheduleRepository()),
            RepositoryProvider.value(value: result.remoteConfigService),
            RepositoryProvider<ISubscriptionRepository>.value(value: result.subscriptionRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<QuickActionsCubit>.value(value: result.quickActionsCubit),
              BlocProvider<ReferralCubit>.value(value: result.referralCubit),
              BlocProvider<PurchaseCubit>.value(value: result.purchaseCubit),
              BlocProvider<RegistrationCubit>.value(value: result.registrationCubit),
              BlocProvider<FuelStationCubit>.value(value: result.fuelStationCubit),
              BlocProvider<MaintenanceCubit>.value(value: result.maintenanceCubit),
              BlocProvider<StatisticsCubit>.value(value: result.statisticsCubit),
              BlocProvider<SubscriptionCubit>.value(value: result.subscriptionCubit),
              BlocProvider<SettingsCubit>.value(value: result.settingsCubit),
              BlocProvider<ReminderCubit>.value(value: result.reminderCubit),
              BlocProvider<AnalyticsCubit>.value(value: result.analyticsCubit),
              BlocProvider<CarInfoCubit>.value(value: result.carInfoCubit),
              BlocProvider<AdditionalOptionsCubit>.value(value: result.additionalOptionsCubit),
              Provider<CurrencyService>.value(value: result.currencyService),
              BlocProvider<CarCubit>.value(value: result.carCubit),
              BlocProvider<ScheduleCubit>(
                create: (context) => ScheduleCubit(
                  repository: context.read<ScheduleRepository>(),
                  maintenanceCubit: result.maintenanceCubit,
                  pushHelper: result.pushHelper,
                  enabled: true,
                  ownerId: '',
                  firebaseRepo: firebaseRepository,
                  carNumber: '',
                  carCubit: context.read<CarCubit>(),
                ),
              ),
              BlocProvider(create: (_) => ExpensesCubit(repository: ExpenseRepository(firestore))),
            ],
            child: MyApp(
              config: result.config,
              flutterLocalNotificationsPlugin: result.flutterLocalNotificationsPlugin,
            ),
          ),
        ),
      );
    },
    (error, stack) {
      _reportStartupError(error, stack);
    },
  );
}
