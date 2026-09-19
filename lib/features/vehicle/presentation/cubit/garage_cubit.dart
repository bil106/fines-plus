import 'dart:async';

import 'package:fines_plus/features/vehicle/data/datasources/car_photo_uploader.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/data/repository/car_info_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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

  /// If [carNumber] is a plate this account already has a car under (e.g.
  /// added earlier from another device), switches to that existing car
  /// instead of minting a duplicate with a fresh carId and orphaning its
  /// expenses/etc.
  ///
  /// [photoPath] is a locally picked photo: it can only be uploaded once the
  /// car exists (its carId is part of the storage path), so it is uploaded
  /// right after creation. A failed upload doesn't undo the new car - the
  /// photo can still be added later by editing it.
  Future<void> addCar({
    String carNumber = '',
    String techPassport = '',
    String make = '',
    String photoUrl = '',
    String photoPath = '',
  }) async {
    if (carNumber.isNotEmpty) {
      final existing = await repository.findCarByNumber(carNumber);
      if (existing != null) {
        await carCubit.switchActiveCar(existing);
        return;
      }
    }

    final car = await repository.addCar(
      carNumber: carNumber,
      techPassport: techPassport,
      make: make,
      photoUrl: photoUrl,
    );
    await carCubit.switchActiveCar(car);

    if (photoPath.isEmpty) return;
    try {
      final url = await CarPhotoUploader().upload(uid: car.ownerId, carId: car.carId, file: XFile(photoPath));
      await updateCar(car, photoUrl: url);
    } catch (e) {
      debugPrint('GarageCubit.addCar: photo upload failed for ${car.carId}: $e');
    }
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
