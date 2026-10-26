import 'package:equatable/equatable.dart';

class CarState extends Equatable {
  final String carNumber;
  final String techPassport;
  final String carId;

  /// The active car's own odometer reading in km (0 = not set), the floor
  /// that expense-record mileages build on.
  final int mileage;
  const CarState({this.carNumber = '', this.techPassport = '', this.carId = '', this.mileage = 0});
  CarState copyWith({String? carNumber, String? techPassport, String? carId, int? mileage}) => CarState(
    carNumber: carNumber ?? this.carNumber,
    techPassport: techPassport ?? this.techPassport,
    carId: carId ?? this.carId,
    mileage: mileage ?? this.mileage,
  );
  @override
  List<Object?> get props => [carNumber, techPassport, carId, mileage];
}
