
import 'package:core_data/core_data.dart';
import 'package:equatable/equatable.dart';


class MaintenanceState extends Equatable {
  final List<ServiceRecord> serviceRecords;
  final List<TuningRecord> tuningRecords;
  final List<FuelRecord> fuelRecords;
  final List<CarWashRecord> carWashRecords;
  final bool isMenuOpen;

  const MaintenanceState({
    this.serviceRecords = const [],
    this.tuningRecords = const [],
    this.fuelRecords = const [],
    this.carWashRecords = const [],
    this.isMenuOpen = false,
  });

  MaintenanceState copyWith({
    List<ServiceRecord>? serviceRecords,
    List<TuningRecord>? tuningRecords,
    List<FuelRecord>? fuelRecords,
    List<CarWashRecord>? carWashRecords,
    bool? isMenuOpen,
  }) {
    return MaintenanceState(
      serviceRecords: serviceRecords ?? this.serviceRecords,
      tuningRecords: tuningRecords ?? this.tuningRecords,
      fuelRecords: fuelRecords ?? this.fuelRecords,
      carWashRecords: carWashRecords ?? this.carWashRecords,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
    );
  }

  @override
  List<Object?> get props => [serviceRecords,tuningRecords,fuelRecords,carWashRecords,isMenuOpen];
}
