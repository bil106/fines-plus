import 'package:equatable/equatable.dart';

class CarState extends Equatable {
  final String carNumber;
  final String techPassport;
  const CarState({this.carNumber = '', this.techPassport = ''});
  CarState copyWith({String? carNumber, String? techPassport}) =>
      CarState(carNumber: carNumber ?? this.carNumber, techPassport: techPassport ?? this.techPassport);
  @override
  List<Object?> get props => [carNumber, techPassport];
}
