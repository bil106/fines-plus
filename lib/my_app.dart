import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/services/launch_service.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_route/auto_route.dart';

import 'core/config/app_config.dart';
import 'router/app_router.dart';

class MyApp extends StatefulWidget {
  final AppConfig config;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final bool isUpdateRequired;

  const MyApp({
    super.key,
    required this.config,
    required this.flutterLocalNotificationsPlugin,
    required this.isUpdateRequired,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  StreamSubscription? _appLinksSub;
  Locale? _locale;

  bool? firstLaunch;
  bool _didNavigate = false; 

  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    
    _initOnce();
  }

  Future<void> _initOnce() async {
 
    firstLaunch = await LaunchService.isFirstLaunch();

  
    _router = AppRouter();

   
    _setupPushNotifications();
    await _initDynamicLinks(); 
    _initAppLinks();

    analytics.logAppOpen();

    if (mounted) setState(() {}); 
  }

  void _setupPushNotifications() {
    FirebaseMessaging.onMessage.listen((message) async {
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
              icon: 'ic_stat_logo',
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Opened the app via notification");
    });
  }

  Future<void> _initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen(
      (data) {
        _handleDeepLink(data.link);
      },
      onError: (err) {
        debugPrint('Dynamic link listen error: $err');
      },
    );

    final initial = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initial != null) _handleDeepLink(initial.link);
  }

  void _handleDeepLink(Uri link) async {
    final partnerId = link.queryParameters['partnerId'];
    if (partnerId != null && partnerId.isNotEmpty) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('pending_ref', partnerId);
    }
    final car = link.queryParameters['car'];
    if (car != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.router.push(HistoryRoute(carNumber: car));
      });
    }
  }

  void _initAppLinks() async {
    _appLinksSub = _appLinks.uriLinkStream.listen(
      (uri) {
        _routeFromAppLink(uri);
      },
      onError: (err) {
        debugPrint("App link error: $err");
      },
    );

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _routeFromAppLink(initialUri);
    } catch (e) {
      debugPrint("Error getting initial app link: $e");
    }
  }

  void _routeFromAppLink(Uri uri) {
    final car = uri.queryParameters['car'];
    final isAddCar = uri.path.contains("addCar");
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (isAddCar) {
          context.router.push( AddCarRoute());
        } else if (car != null) {
          context.router.push(HistoryRoute(carNumber: car));
        }
      });
    }
  }

  @override
  void dispose() {
    _appLinksSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    if (firstLaunch == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

   
    final app = Provider<AppConfig>.value(
      value: widget.config,
      child: MaterialApp.router(
        routerConfig: _router.config(
          deepLinkBuilder: (_) =>
              firstLaunch == true ? const DeepLink([OnboardingRoute()]) : DeepLink([SubscriptionRoute()]),
        ),
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

   
    if (!_didNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
      
        if (widget.isUpdateRequired) {
          context.router.replaceAll([const UpdateRequiredRoute()]);
          _didNavigate = true;
          return;
        }
      
        _didNavigate = true;
      });
    }

    return app;
  }
}


