
// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'package:fines_plus/config/flavor_config.dart';

import 'package:shared_preferences/shared_preferences.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔔 Background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await FirebaseMessaging.instance.requestPermission();


  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'autolux');
  final config = await loadAppConfig(flavor);


  final prefs = await SharedPreferences.getInstance();
  final sharedPrefsManager = SharedPrefsManager(prefs);

 
  final carInfoRepository = CarInfoRepository(
    CarInfoLocalDataSource(sharedPrefsManager),
    CarInfoRemoteDataSource(apiKey: Env.openDataBotApiKey),
  );

  final reminderRepository = ReminderRepository(
    localDataSource: ReminderLocalDataSourceImpl(sharedPrefsManager),
    remoteDataSource: ReminderRemoteDataSourceImpl(FirebaseFirestore.instance),
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CarInfoRepository>.value(value: carInfoRepository),
        RepositoryProvider<ReminderRepository>.value(value: reminderRepository),
      ],
      child: MyApp(config: config, flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin),
    ),
  );
}
