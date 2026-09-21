import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Opens the nearby-gas-stations list, nearest first, each annotated with
/// its distance - the "dropdown" the fuel form's station card opens on tap.
/// Selecting one hands the station back to [onSelected] instead of
/// navigating itself, so callers control what happens next (the fuel form
/// pushes the map focused on it).
void showNearbyStationsSheet(
  BuildContext context, {
  required LatLng currentPosition,
  required List<GasStation> stations,
  required ValueChanged<GasStation> onSelected,
  String? title,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => NearbyStationsSheet(
      currentPosition: currentPosition,
      stations: stations,
      title: title,
      onSelected: (station) {
        Navigator.of(ctx).pop();
        onSelected(station);
      },
    ),
  );
}

class NearbyStationsSheet extends StatelessWidget {
  final LatLng currentPosition;
  final List<GasStation> stations;
  final ValueChanged<GasStation> onSelected;

  /// Header text; defaults to the gas-stations title.
  final String? title;

  const NearbyStationsSheet({
    super.key,
    required this.currentPosition,
    required this.stations,
    required this.onSelected,
    this.title,
  });

  double _distanceKm(GasStation station) =>
      Geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude, station.lat, station.lng) /
      1000;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sorted = [...stations]..sort((a, b) => _distanceKm(a).compareTo(_distanceKm(b)));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.neutreGreyLight,
                  borderRadius: AppBorders.radiusSmall,
                ),
              ),
            ),
            Text(title ?? S.of(context).gas_station_nearby, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final station = sorted[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on, color: AppColors.blueAccent),
                    title: Text(
                      station.vicinity.isEmpty ? station.name : '${station.name} — ${station.vicinity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      S.of(context).distance_km_short(_distanceKm(station).toStringAsFixed(1)),
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.grey700),
                    ),
                    onTap: () => onSelected(station),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
