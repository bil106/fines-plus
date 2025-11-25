import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrialManager {
  static const _keyTrialEnd = "trial_end_timestamp";

  static Future<void> startTrial() async {
    final endDate = DateTime.now().add(const Duration(days: 7));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTrialEnd, endDate.millisecondsSinceEpoch);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isTrial': true,
        'trialEndDate': endDate.millisecondsSinceEpoch,
      });
    }
  }

  static Future<TrialStatus> getTrialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_keyTrialEnd);

    if (ts == null) return TrialStatus.none;

    final endDate = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().isBefore(endDate) ? TrialStatus.active : TrialStatus.expired;
  }
}

enum TrialStatus { none, active, expired }
