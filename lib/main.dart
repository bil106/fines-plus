
// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';
import 'package:core_repository/reminder_repository.dart';
import 'package:fines_plus/env/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:fines_plus/config/flavor_config.dart';
import 'package:fines_plus/theme/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'autolux');
  final config = await loadAppConfig(flavor);

  final prefs = await SharedPreferences.getInstance();
  final sharedPrefsManager = SharedPrefsManager(prefs);

  final carInfoLocalDataSource = CarInfoLocalDataSource(sharedPrefsManager);
  final carInfoRemoteDataSource = CarInfoRemoteDataSource(apiKey: Env.openDataBotApiKey);
  final carInfoRepository = CarInfoRepository(carInfoLocalDataSource, carInfoRemoteDataSource);

  
  final reminderLocalDataSource = ReminderLocalDataSourceImpl(sharedPrefsManager);
  final reminderRemoteDataSource = ReminderRemoteDataSourceImpl(FirebaseFirestore.instance);
  final reminderRepository = ReminderRepository(localDataSource:  reminderLocalDataSource, remoteDataSource: reminderRemoteDataSource, );


  runApp(
MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CarInfoRepository>.value(value: carInfoRepository),
        RepositoryProvider<ReminderRepository>.value(value: reminderRepository),
      ],
      child: MyApp(config: config),
    )

  );
}

class MyApp extends StatefulWidget {
  final AppConfig config;
  const MyApp({super.key, required this.config});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();
  Locale? _locale;

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
