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

  /// Re-runs the screen's own location + nearby lookup; completes when the
  /// lookup is done. Must clear [locationUnavailable] synchronously - that's what keeps the resume
  /// check and the tap from both starting a lookup for one grant (the iOS
  /// permission dialog also triggers a resume).
  Future<void> retryLocation();

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

  /// Tap on the prompt: checks the permission first and asks in-app when the
  /// OS still allows it (the system shows its own dialog). Settings are only
  /// offered when the permission is blocked; with the permission fine but no
  /// position yet, a toast says so instead.
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
    if (!mounted || !locationUnavailable) return;
    await retryLocation();
    if (!mounted || !locationUnavailable) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).location_not_determined)),
    );
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
