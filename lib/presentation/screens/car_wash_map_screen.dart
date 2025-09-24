import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class CarWashMapScreen extends StatefulWidget {
  final LatLng? focusPosition;
  final String? focusName;
  const CarWashMapScreen({super.key, this.focusPosition, this.focusName});

  @override
  State<CarWashMapScreen> createState() => _CarWashMapScreenState();
}

class _CarWashMapScreenState extends State<CarWashMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final String _apiKey = Env.mapApiKey;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission().then((_) => _getCurrentLocation());
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
            infoWindow: InfoWindow(title: S.of(context).my_position),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(current, 14));
      }

      
      final carWashes = await fetchNearbyCarWashes(current, _apiKey);
      setState(() {
        for (int i = 0; i < carWashes.length; i++) {
          final wash = carWashes[i];
          final rating = (wash['rating'] ?? 0).toDouble();

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
              markerId: MarkerId('wash_$i'),
              position: LatLng(wash['lat'], wash['lng']),
              icon: BitmapDescriptor.defaultMarkerWithHue(hue),
              infoWindow: InfoWindow(
                title: wash['name'] ?? 'Car wash',
                snippet:
                    '${wash['vicinity'] ?? S.of(context).address_not_specified}'
                    '${wash['rating'] != null ? ', rating: $rating' : ''}',
              ),
            ),
          );
        }

        if (widget.focusPosition != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('focus_wash'),
              position: widget.focusPosition!,
              infoWindow: InfoWindow(title: widget.focusName ?? 'Selected car wash'),
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
    if (!serviceEnabled) {
      if (kDebugMode) print("⚠️ Geolocation is disabled on the device");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) print("⚠️ Geolocation permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) print("⚠️ Geolocation permission permanently denied");
      return;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).car_wash_nearby)),
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


Future<List<Map<String, dynamic>>> fetchNearbyCarWashes(LatLng location, String apiKey) async {
  final url =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=3000&type=car_wash&key=$apiKey';

  if (kDebugMode) print("🌍 Query Google Places: $url");

  final response = await http.get(Uri.parse(url));

  if (kDebugMode) print("🔎 API Response (${response.statusCode}): ${response.body}");

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      if (kDebugMode) print("⚠️ Error from Google API: ${data['status']} — ${data['error_message']}");
      return [];
    }

    final results = data['results'] as List;

    final washes = results.map((place) {
      final loc = place['geometry']['location'];
      return {
        'lat': loc['lat'],
        'lng': loc['lng'],
        'name': place['name'],
        'vicinity': place['vicinity'],
        'rating': (place['rating'] ?? 0).toDouble(),
      };
    }).toList();

    washes.sort((a, b) => b['rating'].compareTo(a['rating']));

    return washes.take(10).toList();
  } else {
    throw Exception("Error loading car washes");
  }
}
