import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  static RemoteConfigService? _instance;
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService._(this._remoteConfig);

  static Future<RemoteConfigService> init() async {
    if (_instance != null) return _instance!;

    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setDefaults(const {
      'feature_reminders_enabled': true,
      'feature_purchase_enabled': true,
      'min_supported_version': '1.0.1',
    });

    try {
      await remoteConfig.fetchAndActivate();
      debugPrint("RemoteConfig fetched successfully");
      debugPrint("feature_reminders_enabled = ${remoteConfig.getBool('feature_reminders_enabled')}");
      debugPrint("feature_purchase_enabled = ${remoteConfig.getBool('feature_purchase_enabled')}");
    } catch (e) {
      debugPrint('Remote config fetch failed: $e');
    }

    _instance = RemoteConfigService._(remoteConfig);
    return _instance!;
  }

  bool get isRemindersEnabled {
    final val = _remoteConfig.getBool('feature_reminders_enabled');
    debugPrint(" isRemindersEnabled = $val");
    return val;
  }

  bool get isPurchaseEnabled {
    final val = _remoteConfig.getBool('feature_purchase_enabled');
    debugPrint(" isPurchaseEnabled = $val");
    return val;
  }

  Future<void> refresh() async {
    await _remoteConfig.fetchAndActivate();
    debugPrint("Remote config refreshed");
  }
  String get minSupportedVersion {
    final val = _remoteConfig.getString('min_supported_version');
    debugPrint("🔹 minSupportedVersion = $val");
    return val.isNotEmpty ? val : '1.0.1';
  }

}
