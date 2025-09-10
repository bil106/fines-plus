class FuelStationState {
  final Map<String, dynamic>? bestStation;
  final bool isLoading;
  final String? error;

  FuelStationState({this.bestStation, this.isLoading = false, this.error});

  FuelStationState copyWith({Map<String, dynamic>? bestStation, bool? isLoading, String? error}) {
    return FuelStationState(
      bestStation: bestStation ?? this.bestStation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
