import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:fines_plus/features/export/data/repository/injector.dart';
import 'package:fines_plus/features/maintenance/data/repository/maintenance_repository.dart';
import 'package:fines_plus/features/maintenance/data/repository/schedule_firebase_repository.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/fuel_station_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/subscription/data/repository/subscription_repository.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fines_plus/my_app.dart';
import 'package:fines_plus/core/services/app_initializer.dart';
import 'package:shared_preferences/shared_preferences.dart';


late final AppInitializer appInitializer;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("BG Message: ${message.messageId}");
  }
}

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      RequestConfiguration configuration = RequestConfiguration(testDeviceIds: Env.testDeviceIdList);
      MobileAds.instance.updateRequestConfiguration(configuration);
      await MobileAds.instance.initialize();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      appInitializer = AppInitializer();
      final result = await appInitializer.init();
      final firestore = FirebaseFirestore.instance;
      final repository = SharedPrefsMaintenanceRepository(await SharedPreferences.getInstance());
      final firebaseRepository = ScheduleFirebaseRepository(firestore);
      setupLocator();

      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: result.carInfoRepository),
            RepositoryProvider.value(value: result.reminderRepository),
            RepositoryProvider.value(value: result.pushHelper),
            RepositoryProvider.value(value: result.historyRepository),
            RepositoryProvider.value(value: result.firebaseRepository),
            RepositoryProvider<IMaintenanceRepository>.value(value: repository),
            RepositoryProvider<ScheduleRepository>(create: (_) => ScheduleRepository()),
            RepositoryProvider.value(value: result.remoteConfigService),
            RepositoryProvider<ISubscriptionRepository>.value(value: result.subscriptionRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ReferralCubit>.value(value: result.referralCubit),
              BlocProvider<PurchaseCubit>.value(value: result.purchaseCubit),
              BlocProvider<RegistrationCubit>.value(value: result.registrationCubit),
              BlocProvider<FuelStationCubit>.value(value: result.fuelStationCubit),
              BlocProvider<MaintenanceCubit>.value(value: result.maintenanceCubit),
              BlocProvider<StatisticsCubit>.value(value: result.statisticsCubit),
              BlocProvider<SubscriptionCubit>.value(value: result.subscriptionCubit),
              BlocProvider<AdditionalOptionsCubit>.value(value: result.additionalOptionsCubit),
              BlocProvider<CarCubit>.value(value: result.carCubit),
              BlocProvider<ScheduleCubit>(
                create: (context) => ScheduleCubit(
                  repository: context.read<ScheduleRepository>(),
                  maintenanceCubit: result.maintenanceCubit,
                  pushHelper: result.pushHelper,
                  enabled: true,
                  userId: '',
                  firebaseRepo: firebaseRepository,
                  carNumber: '',
                  carCubit: context.read<CarCubit>(),
                )..loadTasks(),
              ),
              BlocProvider(create: (_) => ExpensesCubit(repository: ExpenseRepository(firestore))),
            
            
            ],
            child: MyApp(
              config: result.config,
              flutterLocalNotificationsPlugin: result.flutterLocalNotificationsPlugin,
              isUpdateRequired: result.isUpdateRequired,
            ),
          ),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

