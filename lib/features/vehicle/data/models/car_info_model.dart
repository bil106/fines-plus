import 'package:json_annotation/json_annotation.dart';

part 'car_info_model.g.dart';

@JsonSerializable()
class CarInfoModel {
  final String carNumber;
  final String techPassport;
  final String ownerId;
  final String carId;
  final String make;
  final String model;
  final String photoUrl;

  const CarInfoModel({
    required this.carNumber,
    required this.techPassport,
    required this.ownerId,
    this.carId = '',
    this.make = '',
    this.model = '',
    this.photoUrl = '',
  });

  CarInfoModel copyWith({
    String? carNumber,
    String? techPassport,
    String? ownerId,
    String? carId,
    String? make,
    String? model,
    String? photoUrl,
  }) {
    return CarInfoModel(
      carNumber: carNumber ?? this.carNumber,
      techPassport: techPassport ?? this.techPassport,
      ownerId: ownerId ?? this.ownerId,
      carId: carId ?? this.carId,
      make: make ?? this.make,
      model: model ?? this.model,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory CarInfoModel.fromJson(Map<String, dynamic> json) => _$CarInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CarInfoModelToJson(this);

  static const empty = CarInfoModel(carNumber: '', techPassport: '', ownerId: '');

  /// "Make Model" for display, e.g. "Ford Focus" - either part may be
  /// missing; empty when neither is set.
  String get displayName => [make, model].where((part) => part.isNotEmpty).join(' ');

  /// The placeholder car the app creates on first launch so there is always
  /// an active car id: nothing filled in yet.
  bool get isBlank => carNumber.isEmpty && techPassport.isEmpty && make.isEmpty && model.isEmpty && photoUrl.isEmpty;
}
