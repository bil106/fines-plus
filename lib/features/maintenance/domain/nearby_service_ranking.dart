import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double serviceDistanceKm(Map<String, dynamic> station, LatLng current) =>
    Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      (station['lat'] as num).toDouble(),
      (station['lng'] as num).toDouble(),
    ) /
    1000;

/// Highest rating first; equally rated services are ordered by distance.
/// Unrated services stay available after those with a rating.
List<Map<String, dynamic>> rankNearbyServices(
  List<Map<String, dynamic>> stations,
  LatLng current,
) => [...stations]
  ..sort((a, b) {
    final rating = ((b['rating'] as num?) ?? 0).compareTo(
      (a['rating'] as num?) ?? 0,
    );
    return rating != 0
        ? rating
        : serviceDistanceKm(
            a,
            current,
          ).compareTo(serviceDistanceKm(b, current));
  });
