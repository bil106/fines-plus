import 'package:flutter/services.dart';

/// Named haptic feedback for user actions, so every screen uses the same
/// strength for the same meaning instead of picking raw [HapticFeedback]
/// calls ad hoc. Respects the OS setting: when the user has system haptics
/// turned off, these are silently no-ops.
abstract final class AppHaptics {
  /// A tile or button that opens something (e.g. a quick-add tile).
  /// Not `selectionClick`: on iOS that is the picker-wheel tick, too faint
  /// to notice on a single tap.
  static Future<void> tap() => HapticFeedback.lightImpact();

  /// A record was actually saved - fire only once the result is known,
  /// never on the button press itself.
  static Future<void> success() => HapticFeedback.mediumImpact();

  /// A save was rejected (validation) or failed.
  static Future<void> error() => HapticFeedback.heavyImpact();
}
