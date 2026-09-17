import 'package:fines_plus/features/maintenance/domain/nearby_service_ranking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  const current = LatLng(50.45, 30.52);
  Map<String, dynamic> station(
    String name,
    double latitude, [
    double? rating,
  ]) => {'name': name, 'lat': latitude, 'lng': 30.52, 'rating': rating};

  test('rating takes priority over proximity; ties use distance', () {
    final stations = [
      station('Nearest', 50.4501, 4.1),
      station('Best far', 50.46, 4.9),
      station('Best near', 50.451, 4.9),
      station('Unrated', 50.45001),
    ];
    expect(rankNearbyServices(stations, current).map((s) => s['name']), [
      'Best near',
      'Best far',
      'Nearest',
      'Unrated',
    ]);
    expect(stations.first['name'], 'Nearest');
  });

  test(
    'low-rated and unrated services are retained; empty results are valid',
    () {
      final stations = [
        station('Unrated far', 50.46),
        station('Low', 50.47, 2.0),
        station('Unrated near', 50.451),
      ];
      expect(rankNearbyServices(stations, current).map((s) => s['name']), [
        'Low',
        'Unrated near',
        'Unrated far',
      ]);
      expect(rankNearbyServices([], current), isEmpty);
      expect(serviceDistanceKm(station('Here', 50.45), current), 0);
    },
  );
}
