import 'package:shared_preferences/shared_preferences.dart';

extension SafeBoolPrefs on SharedPreferences {
  bool getBoolSafe(String key, {required bool defaultValue}) {
    final raw = get(key);
    if (raw is bool) return raw;
    if (raw is String) {
      final parsed = raw.toLowerCase() == 'true';
      setBool(key, parsed);
      return parsed;
    }
    return defaultValue;
  }
}
