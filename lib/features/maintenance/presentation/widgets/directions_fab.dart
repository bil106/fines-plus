import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens turn-by-turn directions to [focusPosition] in the device's
/// external Maps app - shared by every "nearby X" map screen (fuel,
/// service/tuning, car wash, ...). Renders nothing when there's no focused
/// station to route to.
class DirectionsFab extends StatelessWidget {
  final LatLng? focusPosition;

  const DirectionsFab({super.key, required this.focusPosition});

  Future<void> _buildRoute(BuildContext context) async {
    final destination = focusPosition;
    if (destination == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=driving',
    );

    // Close this screen (disposing the live GoogleMap) before switching to
    // the external Maps app - some Android devices fail to restore an
    // active GoogleMap's platform view after the app is backgrounded and
    // resumed, leaving a blank white screen with no way back except
    // force-restarting the app.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (focusPosition == null) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: () => _buildRoute(context),
      icon: const Icon(Icons.directions),
      label: Text(S.of(context).build_route),
    );
  }
}
