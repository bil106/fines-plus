import 'package:equatable/equatable.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';

class GarageState extends Equatable {
  final List<CarInfoModel> cars;
  final String activeCarId;
  final bool isLoading;

  /// [cars] without the blank first-launch placeholder, which the garage
  /// doesn't list.
  List<CarInfoModel> get visibleCars => cars.where((car) => !car.isBlank).toList();

  const GarageState({this.cars = const [], this.activeCarId = '', this.isLoading = true});

  GarageState copyWith({List<CarInfoModel>? cars, String? activeCarId, bool? isLoading}) {
    return GarageState(
      cars: cars ?? this.cars,
      activeCarId: activeCarId ?? this.activeCarId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [cars, activeCarId, isLoading];
}
