import 'dart:convert';

import 'package:fines_plus/core/config/app_config.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';

Future<AppConfig> loadRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults({'app_config_json': '{}'});
  await remoteConfig.fetchAndActivate();

  final jsonString = remoteConfig.getString('app_config_json');
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  return AppConfig.fromJson(json);
}
