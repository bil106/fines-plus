import 'package:core_cubit/cubit/fuel_station_cubit.dart';
import 'package:core_cubit/cubit/purchase_cubit.dart';
import 'package:core_cubit/cubit/referral_cubit.dart';
import 'package:core_cubit/cubit/registration_cubit.dart';
import 'package:core_repository/injector.dart';
import 'package:firebase_core/firebase_core.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
        child: MyApp(config: result.config, flutterLocalNotificationsPlugin: result.flutterLocalNotificationsPlugin),
      ),
    ),
  );
}
