import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/maintenance/domain/gas_station_service.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/fuel_station_state.dart';



import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FuelStationCubit extends Cubit<FuelStationState> {
  final GasStationService _gasService;

  FuelStationCubit({GasStationService? gasService})
    : _gasService = gasService ?? GasStationService(Env.mapApiKey),
      super(FuelStationState(isLoading: true));

  Future<void> loadBestStation() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final current = LatLng(position.latitude, position.longitude);

      final stations = await _gasService.fetchNearbyGasStations(current);
      if (stations.isEmpty) {
        emit(state.copyWith(isLoading: false, bestStation: null));
        return;
      }

      final highRated = stations.where((s) => s.rating >= 4.5).toList();
      if (highRated.isEmpty) {
        emit(state.copyWith(isLoading: false, bestStation: null));
        return;
      }

      highRated.sort((a, b) {
        final distA = Geolocator.distanceBetween(current.latitude, current.longitude, a.lat, a.lng);
        final distB = Geolocator.distanceBetween(current.latitude, current.longitude, b.lat, b.lng);
        return distA.compareTo(distB);
      });

      final bestStation = highRated.first;
      emit(state.copyWith(bestStation: bestStation, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
