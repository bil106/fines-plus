import 'package:shared_preferences/shared_preferences.dart';

class TrialManager {
  static const _keyTrialStart = "trial_start_timestamp";

  
  static Future<void> startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTrialStart, DateTime.now().millisecondsSinceEpoch);
  }

 
  static Future<TrialStatus> getTrialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_keyTrialStart);

    if (ts == null) return TrialStatus.none;

    final startDate = DateTime.fromMillisecondsSinceEpoch(ts);
    final now = DateTime.now();
    final diff = now.difference(startDate).inDays;

    if (diff < 7) return TrialStatus.active;

    return TrialStatus.expired;
  }
}

enum TrialStatus { none, active, expired }
