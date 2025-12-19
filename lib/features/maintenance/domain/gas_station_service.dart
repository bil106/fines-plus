import 'dart:convert';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class GasStationService {
  final String apiKey;

  const GasStationService(this.apiKey);

  Future<List<GasStation>> fetchNearbyGasStations(LatLng location) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=3000&type=gas_station&key=$apiKey';

    if (kDebugMode) print("🌍 Query Google Places: $url");

    final response = await http.get(Uri.parse(url));

    if (kDebugMode) print(" API Response (${response.statusCode}): ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load gas stations");
    }

    final data = json.decode(response.body);

    if (data['status'] != 'OK') {
      if (kDebugMode) {
        print(" Error from Google API: ${data['status']} — ${data['error_message']}");
      }
      return [];
    }

    final results = data['results'] as List;

    final stations = results.map((place) {
      final loc = place['geometry']['location'];
      return GasStation(
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
        name: place['name'] as String,
        vicinity: place['vicinity'] as String? ?? '',
        rating: (place['rating'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    stations.sort((a, b) => b.rating.compareTo(a.rating));

    return stations.take(10).toList();
  }
}
