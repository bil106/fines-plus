import 'package:equatable/equatable.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';

abstract class CarInfoStatus extends Equatable {
  const CarInfoStatus();
  @override
  List<Object?> get props => [];
}

class CarInfoInitialStatus extends CarInfoStatus {
  const CarInfoInitialStatus();
}

class CarInfoLoadingStatus extends CarInfoStatus {
  const CarInfoLoadingStatus();
}

class CarInfoLoadedStatus extends CarInfoStatus {
  final List<Map<String, dynamic>> fines;
  const CarInfoLoadedStatus(this.fines);

  @override
  List<Object?> get props => [fines];
}

class CarInfoErrorStatus extends CarInfoStatus {
  final String message;
  const CarInfoErrorStatus(this.message);

  @override
  List<Object?> get props => [message];
}

class CarInfoUnauthorizedStatus extends CarInfoStatus {}

class CarInfoState extends Equatable {
  final String carNumber;
  final String techPassport;
  final CarInfoStatus status;
  final bool hasCheckedFines;
  final CarInfoModel? carDetails;

  const CarInfoState({
    this.carNumber = '',
    this.techPassport = '',
    this.status = const CarInfoInitialStatus(),
    this.hasCheckedFines = false,
    this.carDetails,
  });

  CarInfoState copyWith({
    String? carNumber,
    String? techPassport,
    CarInfoStatus? status,
    bool? hasCheckedFines,
    CarInfoModel? carDetails,
  }) {
    return CarInfoState(
      carNumber: carNumber ?? this.carNumber,
      techPassport: techPassport ?? this.techPassport,
      status: status ?? this.status,
      hasCheckedFines: hasCheckedFines ?? this.hasCheckedFines,
      carDetails: carDetails ?? this.carDetails,
    );
  }

  @override
  List<Object?> get props => [carNumber, techPassport, status, hasCheckedFines, carDetails];
}
