import 'package:shared_preferences/shared_preferences.dart';

/// A local, no-account, no-payment-method 7-day free trial — lets a brand
/// new user use the whole app right after onboarding without registering
/// or subscribing. Once it expires, the existing subscription checks
/// (Firestore-backed, tied to a real account) take back over.
class TrialService {
  static const _startedAtKey = 'trial_started_at';
  static const trialDuration = Duration(days: 7);

  /// Starts the trial clock the first time this is called; safe to call
  /// repeatedly (idempotent).
  static Future<void> ensureStarted() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_startedAtKey) == null) {
      await prefs.setString(_startedAtKey, DateTime.now().toIso8601String());
    }
  }

  static Future<bool> isActive() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_startedAtKey);
    if (raw == null) return false;

    final startedAt = DateTime.tryParse(raw);
    if (startedAt == null) return false;

    return DateTime.now().isBefore(startedAt.add(trialDuration));
  }
}
