import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/env/env.dart';

import 'package:fines_plus/features/maintenance/domain/gas_station_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


@RoutePage()
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
  late final GasStationService _gasService;

  @override
  void initState() {
    super.initState();
    _gasService = GasStationService(Env.mapApiKey);
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

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(current, 14));

      await _loadGasStations(current);
    } catch (e) {
      if (kDebugMode) print("❌ Error getting location: $e");
    }
  }

  Future<void> _loadGasStations(LatLng current) async {
    try {
      final stations = await _gasService.fetchNearbyGasStations(current);

      setState(() {
        for (int i = 0; i < stations.length; i++) {
          final station = stations[i];
          final rating = station.rating;

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
              position: LatLng(station.lat, station.lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(hue),
              infoWindow: InfoWindow(
                title: station.name,
                snippet:
                    '${station.vicinity.isNotEmpty ? station.vicinity : 'Address not specified'}${rating > 0 ? ', rating: ${rating.toStringAsFixed(1)}' : ''}',
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
      if (kDebugMode) print("❌ Error loading gas stations: $e");
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) print("⚠️ Geolocation is disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) print("🚫 Permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) print("⛔ Permission permanently denied");
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
      appBar: AppBar(title: Text(S.of(context).gas_station_nearby)),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              markers: _markers,
              initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 14),
            ),
    );
  }
}
