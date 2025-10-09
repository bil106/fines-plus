import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'router/app_router.dart';

class MyApp extends StatefulWidget {
  final AppConfig config;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MyApp({super.key, required this.config, required this.flutterLocalNotificationsPlugin});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();
  final AppLinks _appLinks = AppLinks();

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  late final ReferralCubit referralCubit;
  StreamSubscription? _appLinksSub;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
    _handleDynamicLinks();
    _initAppLinks();

    analytics.logAppOpen();
  }

  /// Push notifications
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
      debugPrint("➡️ Opened the app via notification");
    });
  }

  /// Firebase Dynamic Links
  void _handleDynamicLinks() async {
   
    FirebaseDynamicLinks.instance.onLink
        .listen((data) {
          final link = data.link;
          _processDynamicLink(link);
        })
        .onError((error) {
          debugPrint("❌ Dynamic Link error: $error");
        });

  
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _processDynamicLink(initialLink.link);
    }
  }


  void _initAppLinks() async {
    _appLinksSub = _appLinks.uriLinkStream.listen(
      (uri) {
        _navigateToHistoryFromAppLink(uri);
      },
      onError: (err) {
        debugPrint("❌ App Link error: $err");
      },
    );

    // Cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _navigateToHistoryFromAppLink(initialUri);
    } catch (e) {
      debugPrint("❌ Error getting initial App Link: $e");
    }
  }


 void _navigateToHistoryFromAppLink(Uri uri) {
    final carNumber = uri.queryParameters['car'];
    final isAddCar = uri.path.contains("addCar");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isAddCar) {
        _appRouter.push(AddCarRoute());
      } else if (carNumber != null) {
        _appRouter.push(HistoryRoute(carNumber: carNumber));
      }
    });
  }


/// Firebase Dynamic Link processing
  void _processDynamicLink(Uri deepLink) async {
    final partnerId = deepLink.queryParameters['partnerId'];
    if (partnerId != null && partnerId.isNotEmpty) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('pending_ref', partnerId);
      debugPrint("💾 Saved partnerId=$partnerId to SharedPreferences");
    }

    final carNumber = deepLink.queryParameters['car'];
    if (carNumber != null) {
      debugPrint("Dynamic Link carNumber: $carNumber");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _appRouter.push(HistoryRoute(carNumber: carNumber));
      });
    }
  }
  
Future<void> savePartnerIdForUser(User user) async {
    final sp = await SharedPreferences.getInstance();
    final partnerId = sp.getString('pending_ref');

    if (partnerId != null && partnerId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email ?? 'unknown',
        'partnerId': partnerId,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("✅ User ${user.email} saved with partnerId=$partnerId");

   // update partner statistics on the client
      await FirebaseFirestore.instance.collection('partnerStats').doc(partnerId).set({
        'registrations': FieldValue.increment(1),
      }, SetOptions(merge: true));

     // clear the local cache
      await sp.remove('pending_ref');
    }
  }



  @override
  void dispose() {
    _appLinksSub?.cancel();
    super.dispose();
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
