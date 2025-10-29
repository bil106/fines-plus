import 'package:equatable/equatable.dart';
import 'package:fines_plus/features/maintenance/data/models/gas_station.dart';


class FuelStationState extends Equatable {
  final bool isLoading;
  final GasStation? bestStation;
  final String? error;

  const FuelStationState({this.isLoading = false, this.bestStation, this.error});

  FuelStationState copyWith({
    bool? isLoading,
    GasStation? bestStation,
    String? error,
  }) {
    return FuelStationState(
      isLoading: isLoading ?? this.isLoading,
      bestStation: bestStation ?? this.bestStation,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, bestStation, error];
}
