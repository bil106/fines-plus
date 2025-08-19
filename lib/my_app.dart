import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';
import 'theme/theme_config.dart';
import 'config/app_config.dart';

class MyApp extends StatefulWidget {
  final AppConfig config;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MyApp({super.key, required this.config, required this.flutterLocalNotificationsPlugin});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();
  Locale? _locale;

  @override
  void initState() {
    super.initState();

    // listener for push notifications when the application is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("📩 Notification received: ${message.notification?.title}");

      final notification = message.notification;
      if (notification != null) {
        await widget.flutterLocalNotificationsPlugin.show(
          0,
          notification.title ?? 'Reminder',
          notification.body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders_channel',
              'Reminders',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
        );
      }
    });

    // opening the application via push
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("➡️ Opened the app via notification");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppConfig>.value(
      value: widget.config,
      child: MaterialApp.router(
        routerConfig: _appRouter.config(),
        title: 'Fines+',
        locale: _locale ?? const Locale('uk'),
        theme: ThemeConfig.createTheme(widget.config),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
