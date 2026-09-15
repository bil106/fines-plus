import 'dart:async';

import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';
import 'package:fines_plus/features/maintenance/domain/gas_station_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Watches the device's position while the app is running (foreground/short
/// background — this is *not* a true always-on geofence that survives the
/// app being fully killed, which would need native region-monitoring code)
/// and prompts the user to log a fuel purchase once they've dwelled at a gas
/// station for a while and then driven off. Driving off is used as a
/// lightweight stand-in for "reconnected to the car after paying" — neither
/// CarPlay nor Android Auto expose a way for a third-party app to detect
/// that directly.
class FuelGeofenceMonitor {
  final GasStationService _gasService;
  final PushHelper _pushHelper;

  static const _arrivalRadiusMeters = 100.0;
  static const _departureRadiusMeters = 250.0;
  static const _minDwellTime = Duration(minutes: 1);
  static const _stationCacheTtl = Duration(minutes: 10);
  static const _stationCacheRadiusMeters = 1000.0;
  static const _notificationId = 778899;

  StreamSubscription<Position>? _positionSub;

  List<GasStation> _cachedStations = [];
  LatLng? _cachedStationsCenter;
  DateTime? _cachedStationsAt;

  GasStation? _currentStation;
  DateTime? _arrivedAt;
  bool _awaitingDeparturePrompt = false;

  FuelGeofenceMonitor(this._gasService, this._pushHelper);

  Future<void> start() async {
    if (_positionSub != null) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint('FuelGeofenceMonitor: location permission not granted, not starting');
      return;
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 40),
    ).listen(_onPosition, onError: (e) => debugPrint('FuelGeofenceMonitor position error: $e'));

    debugPrint('FuelGeofenceMonitor: started');
  }

  void stop() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  Future<void> _onPosition(Position position) async {
    final current = LatLng(position.latitude, position.longitude);
    final stations = await _stationsNear(current);
    if (stations.isEmpty) return;

    GasStation? nearest;
    var nearestDistance = double.infinity;
    for (final s in stations) {
      final d = Geolocator.distanceBetween(current.latitude, current.longitude, s.lat, s.lng);
      if (d < nearestDistance) {
        nearestDistance = d;
        nearest = s;
      }
    }
    if (nearest == null) return;

    if (_currentStation == null) {
      if (nearestDistance <= _arrivalRadiusMeters) {
        _currentStation = nearest;
        _arrivedAt = DateTime.now();
        _awaitingDeparturePrompt = false;
        debugPrint('FuelGeofenceMonitor: arrived at ${nearest.name}');
      }
      return;
    }

    if (nearestDistance <= _arrivalRadiusMeters) {
      if (!_awaitingDeparturePrompt && DateTime.now().difference(_arrivedAt!) >= _minDwellTime) {
        _awaitingDeparturePrompt = true;
      }
      return;
    }

    if (nearestDistance >= _departureRadiusMeters) {
      final shouldPrompt = _awaitingDeparturePrompt;
      debugPrint('FuelGeofenceMonitor: left ${_currentStation!.name}, prompting=$shouldPrompt');
      _currentStation = null;
      _arrivedAt = null;
      _awaitingDeparturePrompt = false;
      if (shouldPrompt) await _promptFuelEntry();
    }
  }

  Future<List<GasStation>> _stationsNear(LatLng position) async {
    final now = DateTime.now();
    final center = _cachedStationsCenter;
    if (center != null &&
        _cachedStationsAt != null &&
        now.difference(_cachedStationsAt!) < _stationCacheTtl &&
        Geolocator.distanceBetween(position.latitude, position.longitude, center.latitude, center.longitude) <
            _stationCacheRadiusMeters) {
      return _cachedStations;
    }

    try {
      final stations = await _gasService.fetchNearbyGasStations(position);
      _cachedStations = stations;
      _cachedStationsCenter = position;
      _cachedStationsAt = now;
      return stations;
    } catch (e) {
      debugPrint('FuelGeofenceMonitor: fetchNearbyGasStations failed: $e');
      return _cachedStations;
    }
  }

  Future<void> _promptFuelEntry() async {
    await _pushHelper.showNow(
      id: _notificationId,
      title: S.current.fuel_prompt_title,
      body: S.current.fuel_prompt_body,
      payload: 'fuel_prompt',
    );
  }
}
