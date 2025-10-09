class CarInfoModel {
  final String carNumber;
  final String techPassport;
  final String ownerId;

  const CarInfoModel({
    required this.carNumber,
    required this.techPassport,
    required this.ownerId,
  });

  CarInfoModel copyWith({String? carNumber, String? techPassport, String? ownerId}) {
    return CarInfoModel(
      carNumber: carNumber ?? this.carNumber,
      techPassport: techPassport ?? this.techPassport,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  static const empty = CarInfoModel(carNumber: '', techPassport: '', ownerId: '');
}
