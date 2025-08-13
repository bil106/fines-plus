import 'package:equatable/equatable.dart';



class CarInfoState extends Equatable {
  final String carNumber;
  final String techPassport;

  const CarInfoState({
    this.carNumber = '',
    this.techPassport = '',
  });

  CarInfoState copyWith({
    String? carNumber,
    String? techPassport,
  }) {
    return CarInfoState(
      carNumber: carNumber ?? this.carNumber,
      techPassport: techPassport ?? this.techPassport,
    );
  }

  @override
  List<Object?> get props => [carNumber, techPassport];
}
