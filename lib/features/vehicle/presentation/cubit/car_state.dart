import 'package:equatable/equatable.dart';

class CarState extends Equatable {
  final String carNumber;
  final String techPassport;
  final String carId;
  const CarState({this.carNumber = '', this.techPassport = '', this.carId = ''});
  CarState copyWith({String? carNumber, String? techPassport, String? carId}) => CarState(
    carNumber: carNumber ?? this.carNumber,
    techPassport: techPassport ?? this.techPassport,
    carId: carId ?? this.carId,
  );
  @override
  List<Object?> get props => [carNumber, techPassport, carId];
}
