


import 'package:fines_plus/my_app.dart';
import 'package:fines_plus/services/app_initializer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


Future<void> main() async {
  final initializer = AppInitializer();
  final result = await initializer.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: result.carInfoRepository),
        RepositoryProvider.value(value: result.reminderRepository),
      ],
      child: MyApp(config: result.config, flutterLocalNotificationsPlugin: result.flutterLocalNotificationsPlugin),
    ),
  );
}
