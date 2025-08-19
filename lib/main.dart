import 'package:fines_plus/my_app.dart';
import 'package:fines_plus/services/app_initializer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("📩 BG Message: ${message.messageId}");
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
late final AppInitializer appInitializer;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  appInitializer = AppInitializer();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const String soundFileName = 'notify';
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'reminders_channel',
    'Reminders',
    description: 'Channel for reminders',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(soundFileName),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final initializer = AppInitializer();
  final result = await initializer.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: result.carInfoRepository),
        RepositoryProvider.value(value: result.reminderRepository),
        RepositoryProvider.value(value: result.pushHelper),
      ],
      child: MyApp(config: result.config, flutterLocalNotificationsPlugin: result.flutterLocalNotificationsPlugin),
    ),
  );
}
