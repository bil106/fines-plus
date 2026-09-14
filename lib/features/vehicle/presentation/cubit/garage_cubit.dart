import 'dart:async';

import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'garage_state.dart';

/// Owns the signed-in user's list of cars (the "garage") and orchestrates
/// switching/adding/editing/deleting them, keeping [CarCubit] (the single
/// "active car" the rest of the app reads from) in sync.
class GarageCubit extends Cubit<GarageState> {
  final CarInfoRepository repository;
  final CarCubit carCubit;
  late final StreamSubscription<List<CarInfoModel>> _carsSub;
  late final StreamSubscription<dynamic> _activeSub;

  GarageCubit({required this.repository, required this.carCubit})
    : super(GarageState(activeCarId: carCubit.state.carId)) {
    _carsSub = repository.streamCars().listen((cars) {
      emit(state.copyWith(cars: cars, isLoading: false));
    });
    _activeSub = carCubit.stream.listen((carState) {
      emit(state.copyWith(activeCarId: carState.carId));
    });
  }

  Future<void> addCar({String carNumber = '', String techPassport = '', String make = '', String photoUrl = ''}) async {
    final car = await repository.addCar(
      carNumber: carNumber,
      techPassport: techPassport,
      make: make,
      photoUrl: photoUrl,
    );
    await carCubit.switchActiveCar(car);
  }

  Future<void> switchTo(CarInfoModel car) => carCubit.switchActiveCar(car);

  Future<void> updateCar(
    CarInfoModel car, {
    String? carNumber,
    String? techPassport,
    String? make,
    String? photoUrl,
  }) async {
    if (car.carId == carCubit.state.carId) {
      if (carNumber != null) await carCubit.changeCar(carNumber);
      if (techPassport != null) await carCubit.setTechPassport(techPassport);
      if (make != null) await carCubit.setMake(make);
      if (photoUrl != null) await carCubit.setPhotoUrl(photoUrl);
    } else {
      await repository.updateCarFields(
        car.carId,
        carNumber: carNumber,
        techPassport: techPassport,
        make: make,
        photoUrl: photoUrl,
      );
    }
  }

  Future<void> deleteCar(CarInfoModel car) async {
    final wasActive = car.carId == carCubit.state.carId;
    await repository.deleteGarageCar(car.carId);

    if (!wasActive) return;

    final remaining = state.cars.where((c) => c.carId != car.carId).toList();
    if (remaining.isNotEmpty) {
      await carCubit.switchActiveCar(remaining.first);
    } else {
      await carCubit.resetToNewDefaultCar();
    }
  }

  @override
  Future<void> close() {
    _carsSub.cancel();
    _activeSub.cancel();
    return super.close();
  }
}
