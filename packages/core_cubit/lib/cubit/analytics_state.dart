
part of 'analytics_cubit.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsState {
  final AnalyticsStatus status;
  final DateTime? selectedDate;
  final String fuelLiters;
  final double fuelCost;
  final int mileage;

  AnalyticsState({
    required this.status,
    this.selectedDate,
    this.fuelLiters = '',
    this.fuelCost = 0,
    this.mileage = 0,
  });

  factory AnalyticsState.initial() => AnalyticsState(status: AnalyticsStatus.initial);

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    DateTime? selectedDate,
    String? fuelLiters,
    double? fuelCost,
    int? mileage,
  }) =>
      AnalyticsState(
        status: status ?? this.status,
        selectedDate: selectedDate ?? this.selectedDate,
        fuelLiters: fuelLiters ?? this.fuelLiters,
        fuelCost: fuelCost ?? this.fuelCost,
        mileage: mileage ?? this.mileage,
      );
}
