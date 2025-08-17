// ignore_for_file: depend_on_referenced_packages, unnecessary_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fines_plus/config/flavor_config.dart';
import 'package:fines_plus/env/env.dart';

import '../config/app_config.dart';

class AppInitializer {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("🔔 Background message: ${message.messageId}");
  }

  Future<AppInitResult> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // FCM permissions
    await FirebaseMessaging.instance.requestPermission();

    // Load config
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'autolux');
    final config = await loadAppConfig(flavor);

    // SharedPrefs
    final prefs = await SharedPreferences.getInstance();
    final sharedPrefsManager = SharedPrefsManager(prefs);

    // Репозитории
    final carInfoRepository = CarInfoRepository(
      CarInfoLocalDataSource(sharedPrefsManager),
      CarInfoRemoteDataSource(apiKey: Env.openDataBotApiKey),
    );

    final reminderRepository = ReminderRepository(
      localDataSource: ReminderLocalDataSourceImpl(sharedPrefsManager),
      remoteDataSource: ReminderRemoteDataSourceImpl(FirebaseFirestore.instance),
    );

    return AppInitResult(
      config: config,
      carInfoRepository: carInfoRepository,
      reminderRepository: reminderRepository,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  }
}


class AppInitResult {
  final AppConfig config;
  final CarInfoRepository carInfoRepository;
  final ReminderRepository reminderRepository;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  AppInitResult({
    required this.config,
    required this.carInfoRepository,
    required this.reminderRepository,
    required this.flutterLocalNotificationsPlugin,
  });
}
