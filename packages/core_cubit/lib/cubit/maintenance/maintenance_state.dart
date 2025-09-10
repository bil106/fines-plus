
import 'package:core_data/core_data.dart';
import 'package:equatable/equatable.dart';


class MaintenanceState extends Equatable {
  final List<ServiceRecord> serviceRecords;
  final List<FuelRecord> fuelRecords;
  final bool isMenuOpen;

  const MaintenanceState({
    this.serviceRecords = const [],
    this.fuelRecords = const [],
    this.isMenuOpen = false,
  });

  MaintenanceState copyWith({
    List<ServiceRecord>? serviceRecords,
    List<FuelRecord>? fuelRecords,
    bool? isMenuOpen,
  }) {
    return MaintenanceState(
      serviceRecords: serviceRecords ?? this.serviceRecords,
      fuelRecords: fuelRecords ?? this.fuelRecords,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
    );
  }

  @override
  List<Object?> get props => [serviceRecords, fuelRecords, isMenuOpen];
}
