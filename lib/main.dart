import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/my_app.dart';
import 'package:fines_plus/services/app_initializer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

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

  GRecaptchaV3.ready(Env.recaptchaSiteKey);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  appInitializer = AppInitializer();
  final result = await appInitializer.init();

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
