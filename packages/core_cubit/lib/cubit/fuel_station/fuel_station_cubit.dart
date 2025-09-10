import 'package:core_cubit/cubit/fuel_station/fuel_station_state.dart';
import 'package:fines_plus/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/env/env.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FuelStationCubit extends Cubit<FuelStationState> {
  FuelStationCubit() : super(FuelStationState(isLoading: true));

  Future<void> loadBestStation() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng current = LatLng(position.latitude, position.longitude);
      final apiKey = Env.mapApiKey;
      final station = await _fetchBestNearbyGasStation(current, apiKey);
      emit(state.copyWith(bestStation: station, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<Map<String, dynamic>?> _fetchBestNearbyGasStation(LatLng current, String apiKey) async {
    final stations = await fetchNearbyGasStations(current, 'AIzaSyD8El-2EaU3iDuHLre3_Mz218iU-l1sr48');
    if (stations.isEmpty) return null;

    final highRated = stations.where((s) => (s['rating'] ?? 0) >= 4.5).toList();
    if (highRated.isEmpty) return null;

    highRated.sort((a, b) {
      final distA = Geolocator.distanceBetween(current.latitude, current.longitude, a['lat'], a['lng']);
      final distB = Geolocator.distanceBetween(current.latitude, current.longitude, b['lat'], b['lng']);
      return distA.compareTo(distB);
    });

    return highRated.first;
  }
}
