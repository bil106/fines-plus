import 'dart:async';

import 'package:core_cubit/cubit/fuel_station/fuel_station_cubit.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:core_cubit/cubit/registration/registration_cubit.dart';
import 'package:core_repository/injector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fines_plus/my_app.dart';
import 'package:fines_plus/services/app_initializer.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("📩 BG Message: ${message.messageId}");
  }
}

late final AppInitializer appInitializer;

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      await MobileAds.instance.initialize();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      appInitializer = AppInitializer();
      final result = await appInitializer.init();
      setupLocator();

      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: result.carInfoRepository),
            RepositoryProvider.value(value: result.reminderRepository),
            RepositoryProvider.value(value: result.pushHelper),
            RepositoryProvider.value(value: result.historyRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ReferralCubit>.value(value: result.referralCubit),
              BlocProvider<PurchaseCubit>.value(value: result.purchaseCubit),
              BlocProvider<RegistrationCubit>.value(value: result.registrationCubit),
              BlocProvider<FuelStationCubit>.value(value: result.fuelStationCubit),
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
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

