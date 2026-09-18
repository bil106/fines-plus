import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/maintenance/domain/nearby_service_ranking.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Map<String, dynamic>?> showNearbyServicesSheet(
  BuildContext context, {
  required LatLng currentPosition,
  required List<Map<String, dynamic>> stations,
  String? title,
  IconData icon = Icons.build_outlined,
}) {
  final sorted = rankNearbyServices(stations, currentPosition);
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.brandTheme.surfaceBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
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
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  title ?? S.of(context).service_station_nearby,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final station = sorted[index];
                      final rating = (station['rating'] as num?) ?? 0;
                      final address = station['vicinity'] as String? ?? '';
                      return Material(
                        color: AppColors.neutreBlanc,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: context.brandTheme.surfaceBorder,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(icon, color: AppColors.blueAccent),
                          title: Text(
                            station['name'] as String,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (address.isNotEmpty) Text(address),
                              Text(
                                [
                                  rating > 0
                                      ? '★ ${rating.toStringAsFixed(1)}'
                                      : S.of(context).service_no_rating,
                                  S
                                      .of(context)
                                      .distance_km_short(
                                        serviceDistanceKm(
                                          station,
                                          currentPosition,
                                        ).toStringAsFixed(1),
                                      ),
                                ].join(' · '),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.grey700,
                          ),
                          onTap: () => Navigator.of(context).pop(station),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
