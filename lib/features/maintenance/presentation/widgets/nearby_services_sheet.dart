import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/maintenance/domain/nearby_service_ranking.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                      color: context.brandTheme.surfaceBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  title ?? S.of(context).service_station_nearby,
                  style: textTheme.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink),
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
                        elevation: 2,
                        shadowColor: AppColors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: context.brandTheme.surfaceBorder,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
                          title: Text(
                            station['name'] as String,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (address.isNotEmpty)
                                Text(address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Builder(
                                builder: (context) {
                                  final settingsCubit = context.watch<SettingsCubit>();
                                  final converted = UnitStream(settingsCubit).convert(
                                    serviceDistanceKm(station, currentPosition),
                                  );
                                  final unit = settingsCubit.state.unit == 'mil' ? 'mi' : S.of(context).km;
                                  return Text(
                                    [
                                      rating > 0
                                          ? '★ ${rating.toStringAsFixed(1)}'
                                          : S.of(context).service_no_rating,
                                      S.of(context).distance_km_short(converted.toStringAsFixed(1), unit),
                                    ].join(' · '),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  );
                                },
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.catOther,
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
