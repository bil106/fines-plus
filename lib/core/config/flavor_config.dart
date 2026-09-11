import 'dart:convert';

import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/services.dart';

Future<AppConfig> loadAppConfig(String flavor) async {
  final configString = await rootBundle.loadString('assets/config/$flavor.json');
  final json = jsonDecode(configString) as Map<String, dynamic>;
  return AppConfig.fromJson(json);
}
