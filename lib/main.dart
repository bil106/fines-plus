import 'package:core_localization/localization/generated/l10n.dart';
import 'package:fines_plus/config/flavor_config.dart';
import 'package:fines_plus/theme/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';

import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'autolux');
  final config = await loadAppConfig(flavor);

  runApp(MyApp(config: config));
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


