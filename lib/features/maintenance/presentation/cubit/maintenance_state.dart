import 'package:equatable/equatable.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';


class MaintenanceState extends Equatable {
  final List<ServiceRecord> serviceRecords;
  final List<TuningRecord> tuningRecords;
  final List<FuelRecord> fuelRecords;
  final List<CarWashRecord> carWashRecords;
  final bool isMenuOpen;
  final bool isLoading;

  const MaintenanceState({
    this.serviceRecords = const [],
    this.tuningRecords = const [],
    this.fuelRecords = const [],
    this.carWashRecords = const [],
    this.isMenuOpen = false,
    this.isLoading = false,
  });

  MaintenanceState copyWith({
    List<ServiceRecord>? serviceRecords,
    List<TuningRecord>? tuningRecords,
    List<FuelRecord>? fuelRecords,
    List<CarWashRecord>? carWashRecords,
    bool? isMenuOpen,
    bool? isLoading, 
  }) {
    return MaintenanceState(
      serviceRecords: serviceRecords ?? this.serviceRecords,
      tuningRecords: tuningRecords ?? this.tuningRecords,
      fuelRecords: fuelRecords ?? this.fuelRecords,
      carWashRecords: carWashRecords ?? this.carWashRecords,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [serviceRecords,tuningRecords,fuelRecords,carWashRecords,isMenuOpen,
        isLoading,
      ];
}
