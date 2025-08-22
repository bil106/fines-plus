// ignore_for_file: depend_on_referenced_packages, unnecessary_import

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:fines_plus/backend/fines_server.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
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

 
    final finesServer = FinesServer();
    await finesServer.start();

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
        debugPrint('📩 Notification tapped! Payload: ${details.payload}');
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
      debugPrint("🔑 FCM Registration Token: $token");
    }

    final firestore = FirebaseFirestore.instance;
    final remindersSnapshot = await firestore.collection('reminders').get();

    for (var carDoc in remindersSnapshot.docs) {
      final itemsSnapshot = await carDoc.reference.collection('items').get();
      for (var itemDoc in itemsSnapshot.docs) {
        final data = itemDoc.data();
        final dateValue = data['dateTime'];
        if (dateValue is Timestamp) {
          final reminder = ReminderModel(
            id: itemDoc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            dateTime: dateValue.toDate(),
            isCompleted: data['isCompleted'] ?? false,
          );
          await scheduleReminder(reminder);
        }
      }
    }

    debugPrint('✅ All reminders scheduled');

    // Load config
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'autolux');
    final config = await loadAppConfig(flavor);

    // SharedPrefs
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

    final pushHelper = PushHelper(flutterLocalNotificationsPlugin);

    return AppInitResult(
      config: config,
      carInfoRepository: carInfoRepository,
      reminderRepository: reminderRepository,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      pushHelper: pushHelper,
    );
  }

  Future<void> startNodeServer() async {
    debugPrint('🚀 Запуск Node.js сервера...');
    final process = await Process.start('node', ['index.js']);

    process.stdout.transform(SystemEncoding().decoder).listen((line) {
      debugPrint('🟢 Node: $line');
    });

    process.stderr.transform(SystemEncoding().decoder).listen((line) {
      debugPrint('🔴 Node error: $line');
    });
  }

  Future<void> _waitForServer({int retries = 5}) async {
    final client = http.Client();
    for (int i = 0; i < retries; i++) {
      try {
        final response = await client.get(Uri.parse('http://127.0.0.1:3000/')).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          debugPrint('✅ Сервер доступен');
          return;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 1));
    }
    throw Exception('Сервер недоступен после $retries попыток');
  }
}

extension ReminderScheduling on AppInitializer {
  Future<void> scheduleReminder(ReminderModel reminder) async {
    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

    debugPrint('🔔 Reminder ${reminder.id} scheduled in $scheduledDate');

    Future.delayed(Duration(seconds: 1), () async {
      const String soundFileName = 'notify';
      await flutterLocalNotificationsPlugin.show(
        reminder.id.hashCode,
        reminder.title,
        reminder.description,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Reminder',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(soundFileName),
          ),
        ),
        payload: reminder.id,
      );
      debugPrint('🔔 Reminder ${reminder.id} triggered at ${DateTime.now()}');
    });
  }
}

class AppInitResult {
  final AppConfig config;
  final CarInfoRepository carInfoRepository;
  final ReminderRepository reminderRepository;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final PushHelper pushHelper;

  AppInitResult({
    required this.config,
    required this.carInfoRepository,
    required this.reminderRepository,
    required this.flutterLocalNotificationsPlugin,
    required this.pushHelper,
  });
}
