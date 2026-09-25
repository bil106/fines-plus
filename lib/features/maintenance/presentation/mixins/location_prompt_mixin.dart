import 'package:flutter/widgets.dart';
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
  /// opens the exact settings screen where location can be turned on.
  Future<void> enableLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }
    if (permission == LocationPermission.denied) return;
    if (mounted && locationUnavailable) retryLocation();
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
