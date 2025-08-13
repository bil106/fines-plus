class CarInfoModel {
  final String carNumber;
  final String techPassport;

  const CarInfoModel({required this.carNumber, required this.techPassport});

  CarInfoModel copyWith({String? carNumber, String? techPassport}) {
    return CarInfoModel(carNumber: carNumber ?? this.carNumber, techPassport: techPassport ?? this.techPassport);
  }

  static const empty = CarInfoModel(carNumber: '', techPassport: '');
}
