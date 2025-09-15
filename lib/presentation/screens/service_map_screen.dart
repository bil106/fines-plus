import 'dart:convert';

import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ServiceMapScreen extends StatefulWidget {
  final LatLng? focusPosition;
  final String? focusName;
  const ServiceMapScreen({super.key, this.focusPosition, this.focusName});

  @override
  State<ServiceMapScreen> createState() => _ServiceMapScreenState();
}

class _ServiceMapScreenState extends State<ServiceMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final String _apiKey = Env.mapApiKey;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission().then((_) => _getCurrentLocation());
  }
  @override
  void dispose() {
    _mapController?.dispose(); 
    super.dispose();
  }
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final current = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = current;
        _markers.add(
          Marker(
            markerId: const MarkerId('my_location'),
            position: current,
            infoWindow:  InfoWindow(title: S.of(context).my_position),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(current, 14));
      }

     
      final services = await fetchNearbyServices(current, _apiKey);
      setState(() {
        for (int i = 0; i < services.length; i++) {
          final service = services[i];
          final rating = (service['rating'] ?? 0).toDouble();
          double hue;
          if (rating >= 4.5) {
            hue = BitmapDescriptor.hueGreen;
          } else if (rating >= 3.5) {
            hue = BitmapDescriptor.hueYellow;
          } else {
            hue = BitmapDescriptor.hueRed;
          }
          _markers.add(
            Marker(
              markerId: MarkerId('service_$i'),
              position: LatLng(service['lat'], service['lng']),
              icon: BitmapDescriptor.defaultMarkerWithHue(hue),
              infoWindow: InfoWindow(
                title: service['name'] ?? S.of(context).service_station,
                snippet:
                    '${service['vicinity'] ?? S.of(context).address_not_specified}${service['rating'] != null ? ', rating: $rating' : ''}',
              ),
            ),
          );
        }

        if (widget.focusPosition != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('focus_service'),
              position: widget.focusPosition!,
              infoWindow: InfoWindow(title: widget.focusName ?? S.of(context).selected_service_station),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );

          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(widget.focusPosition!, 16));
        }
      });
    } catch (e) {
      if (kDebugMode) print("❌ Error getting geolocation: $e");
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(S.of(context).service_station_nearby)),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? const LatLng(50.4501, 30.5234),
                zoom: 14,
              ),
            ),
    );
  }
}
Future<List<Map<String, dynamic>>> fetchNearbyServices(LatLng location, String apiKey) async {
  final url =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${location.latitude},${location.longitude}'
      '&radius=3000'
      '&type=car_repair'
      '&keyword=автосервис'
      '&key=$apiKey';

  if (kDebugMode) {
    print("🌍 Query Google Places (services): $url");
  }

  final response = await http.get(Uri.parse(url));

  if (kDebugMode) {
    print("🔎 API Response (${response.statusCode}): ${response.body}");
  }

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      if (kDebugMode) {
        print("⚠️ Error from Google API: ${data['status']} — ${data['error_message']}");
      }
      return [];
    }

    final results = data['results'] as List;

    final services = results.map((place) {
      final loc = place['geometry']['location'];
      return {
        'lat': loc['lat'],
        'lng': loc['lng'],
        'name': place['name'],
        'vicinity': place['vicinity'],
        'rating': (place['rating'] ?? 0).toDouble(),
      };
    }).toList();


    services.sort((a, b) => b['rating'].compareTo(a['rating']));

  return services.take(10).toList();
  } else {
    throw Exception("Error loading services");
  }
}

