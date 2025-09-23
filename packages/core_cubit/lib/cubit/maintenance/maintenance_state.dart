
import 'package:core_data/core_data.dart';
import 'package:equatable/equatable.dart';


class MaintenanceState extends Equatable {
  final List<ServiceRecord> serviceRecords;
  final List<TuningRecord> tuningRecords;
  final List<FuelRecord> fuelRecords;
  final bool isMenuOpen;

  const MaintenanceState({
    this.serviceRecords = const [],
    this.tuningRecords = const [],
    this.fuelRecords = const [],
    this.isMenuOpen = false,
  });

  MaintenanceState copyWith({
    List<ServiceRecord>? serviceRecords,
    List<TuningRecord>? tuningRecords,
    List<FuelRecord>? fuelRecords,
    bool? isMenuOpen,
  }) {
    return MaintenanceState(
      serviceRecords: serviceRecords ?? this.serviceRecords,
      tuningRecords: tuningRecords ?? this.tuningRecords,
      fuelRecords: fuelRecords ?? this.fuelRecords,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
    );
  }

  @override
  List<Object?> get props => [serviceRecords,tuningRecords,fuelRecords, isMenuOpen];
}
