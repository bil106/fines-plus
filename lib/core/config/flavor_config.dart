import 'dart:convert';

import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/services.dart';

/// Brand flavor passed as `--dart-define=FLAVOR=<flavor>`.
// No --dart-define=FLAVOR is passed anywhere in this repo's run/build
// configs (checked: no CI, no fastlane, no .vscode/.idea launch config) -
// so this default is what the real, currently-shipping app actually
// resolves to. It must be the real brand, not a demo/test one.
const currentFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'finesplus');

Future<AppConfig> loadAppConfig(String flavor) async {
  final configString = await rootBundle.loadString('assets/config/$flavor.json');
  final json = jsonDecode(configString) as Map<String, dynamic>;
  return AppConfig.fromJson(json);
}
