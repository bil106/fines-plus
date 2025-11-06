import 'package:shared_preferences/shared_preferences.dart';

class LaunchService {
  static const _key = 'isFirstLaunch';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(_key) ?? true;

    if (isFirst) {
      await prefs.setBool(_key, false);
    }

    return isFirst;
  }
}
