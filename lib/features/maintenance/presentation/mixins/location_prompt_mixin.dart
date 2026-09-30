import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Shared "allow location" flow for the forms that suggest a nearby place
/// (fuel, service, car wash, tuning): tapping the prompt turns location on
/// from inside the app instead of making the user hunt through settings.
mixin LocationPromptMixin<T extends StatefulWidget> on State<T> {
  late final AppLifecycleListener _locationLifecycleListener;

  /// Whether the form is currently showing the "allow location" prompt.
  bool get locationUnavailable;

  /// Re-runs the screen's own location + nearby lookup. Must clear
  /// [locationUnavailable] synchronously - that's what keeps the resume
  /// check and the tap from both starting a lookup for one grant (the iOS
  /// permission dialog also triggers a resume).
  void retryLocation();

  @override
  void initState() {
    super.initState();
    // Back from system settings with location now on.
    _locationLifecycleListener = AppLifecycleListener(
      onResume: _recheckLocationOnResume,
    );
  }

  @override
  void dispose() {
    _locationLifecycleListener.dispose();
    super.dispose();
  }

  /// Tap on the prompt: asks in-app when the OS still allows it, otherwise
  /// opens the app's settings screen where location can be turned on.
  Future<void> enableLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      await _openAppSettings();
      return;
    }
    if (permission == LocationPermission.denied) return;
    // Already allowed, yet the screen still has no position (e.g. iOS with
    // no fix): re-asking is pointless, so send the user to the app's
    // settings; the resume check retries when they come back.
    await _openAppSettings();
  }

  /// iOS can only open the app's settings page, not the location switch
  /// itself, so a short hint says where to tap before leaving the app.
  Future<void> _openAppSettings() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(S.of(ctx).location_settings_title),
          content: Text(S.of(ctx).location_settings_steps),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(S.of(ctx).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(S.of(ctx).location_open_settings),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    await Geolocator.openAppSettings();
  }

  /// Checks silently - never pops a permission dialog just because the
  /// user came back to the app.
  Future<void> _recheckLocationOnResume() async {
    if (!locationUnavailable) return;
    final permission = await Geolocator.checkPermission();
    if (!await Geolocator.isLocationServiceEnabled() ||
        permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    if (mounted && locationUnavailable) retryLocation();
  }
}
