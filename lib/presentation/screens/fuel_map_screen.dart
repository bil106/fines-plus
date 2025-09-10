import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class FuelMapScreen extends StatefulWidget {
  final LatLng? focusPosition;
  final String? focusName;
  const FuelMapScreen({super.key, this.focusPosition, this.focusName});

  @override
  State<FuelMapScreen> createState() => _FuelMapScreenState();
}

class _FuelMapScreenState extends State<FuelMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final String _apiKey = 'AIzaSyD8El-2EaU3iDuHLre3_Mz218iU-l1sr48';

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
            infoWindow: const InfoWindow(title: 'You are here'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(current, 14));
      }

      // Loading gas stations
      final gasStations = await fetchNearbyGasStations(current, _apiKey);
      setState(() {
        for (int i = 0; i < gasStations.length; i++) {
          final station = gasStations[i];
          final rating = (station['rating'] ?? 0).toDouble();
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
              markerId: MarkerId('gas_$i'),
              position: LatLng(station['lat'], station['lng']),
              icon: BitmapDescriptor.defaultMarkerWithHue(hue),
              infoWindow: InfoWindow(
                title: station['name'] ?? 'Refueling',
                snippet:
                    '${station['vicinity'] ?? 'Address not specified'}${station['rating'] != null ? ', рейтинг: $rating' : ''}',
              ),
            ),
          );
        }

        if (widget.focusPosition != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('focus_station'),
              position: widget.focusPosition!,
              infoWindow: InfoWindow(title: widget.focusName ?? 'Selected gas station'),
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
      if (kDebugMode) {
        print("⚠️ Geolocation is disabled on the device");
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print("⚠️ Geolocation permission denied");
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print("⚠️ Geolocation permission permanently denied");
      }
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
      appBar: AppBar(title: const Text("Заправки поряд")),
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

Future<List<Map<String, dynamic>>> fetchNearbyGasStations(LatLng location, String apiKey) async {
  final url =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=3000&type=gas_station&key=$apiKey';

  if (kDebugMode) {
    print("🌍 Query Google Places: $url");
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

    final stations = results.map((place) {
      final loc = place['geometry']['location'];
      return {
        'lat': loc['lat'],
        'lng': loc['lng'],
        'name': place['name'],
        'vicinity': place['vicinity'],
        'rating': (place['rating'] ?? 0).toDouble(),
      };
    }).toList();

    stations.sort((a, b) => b['rating'].compareTo(a['rating']));

    return stations.take(10).toList();
  } else {
    throw Exception("Error loading gas stations");
  }
}
