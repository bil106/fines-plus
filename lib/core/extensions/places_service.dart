// services/places_service.dart
import 'dart:convert';
import 'package:core/config/app_urls.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<LatLng>> fetchNearbyGasStations(LatLng location, String apiKey) async {
final url = AppUrls.nearbyGasStations(location, apiKey);
  final response = await http.get(Uri.parse(url));


  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'] as List;
    return results.map((place) {
      final loc = place['geometry']['location'];
      return LatLng(loc['lat'], loc['lng']);
    }).toList();
  } else {
    throw Exception("Error loading gas stations");
  }
}
