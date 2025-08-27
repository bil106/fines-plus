import 'package:equatable/equatable.dart';

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

class CarInfoState extends Equatable {
  final String carNumber;
  final String techPassport;
  final CarInfoStatus status;

  const CarInfoState({
    this.carNumber = '',
    this.techPassport = '',
    this.status = const CarInfoInitialStatus(),
  });

  CarInfoState copyWith({
    String? carNumber,
    String? techPassport,
    CarInfoStatus? status,
  }) {
    return CarInfoState(
      carNumber: carNumber ?? this.carNumber,
      techPassport: techPassport ?? this.techPassport,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [carNumber, techPassport, status];
}
