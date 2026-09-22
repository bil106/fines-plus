import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    backgroundColor: context.brandTheme.surfaceBg,
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
                  color: context.brandTheme.surfaceBorder,
                  borderRadius: AppBorders.radiusSmall,
                ),
              ),
            ),
            Text(
              title ?? S.of(context).gas_station_nearby,
              style: textTheme.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final station = sorted[index];
                  return Material(
                    color: AppColors.neutreBlanc,
                    elevation: 2,
                    shadowColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.brandTheme.surfaceBorder),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                      title: Text(
                        station.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (station.vicinity.isNotEmpty)
                            Text(station.vicinity, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Builder(
                            builder: (context) {
                              final settingsCubit = context.watch<SettingsCubit>();
                              final converted = UnitStream(settingsCubit).convert(_distanceKm(station));
                              final unit = settingsCubit.state.unit == 'mil' ? 'mi' : S.of(context).km;
                              return Text(
                                [
                                  station.rating > 0 ? '★ ${station.rating.toStringAsFixed(1)}' : S.of(context).service_no_rating,
                                  S.of(context).distance_km_short(converted.toStringAsFixed(1), unit),
                                ].join(' · '),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              );
                            },
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.catOther),
                      onTap: () => onSelected(station),
                    ),
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
