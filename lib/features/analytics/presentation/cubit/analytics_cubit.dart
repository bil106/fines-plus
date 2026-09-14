import 'dart:async';

import 'package:fines_plus/features/analytics/data/repository/analytics_repository.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository repository;
  final CarCubit carCubit;
  late final StreamSubscription _carSub;
  bool _isClosed = false;

  AnalyticsCubit({required this.repository, required this.carCubit}) : super(AnalyticsState.initial()) {
    _carSub = carCubit.stream.listen((carState) {
      final carId = carState.carId;

      if (_isClosed) return;
      if (carId.isEmpty) return;

      _reloadForCar(carId);
    });
  }

  Future<void> _reloadForCar(String carNumber) async {
    if (_isClosed || carNumber.isEmpty) return;

    try {
      emit(state.copyWith(status: AnalyticsStatus.loading));

      final date = state.selectedDate ?? DateTime.now();
      final data = await repository.getAnalytics(date, carNumber);

      if (_isClosed) return;

      emit(
        state.copyWith(
          status: AnalyticsStatus.loaded,
          fuelLiters: data.fuelLiters.toString(),
          fuelCost: data.fuelCost,
          mileage: data.mileage,
        ),
      );
    } catch (e, st) {
      debugPrint("AnalyticsCubit error: $e\n$st");
      if (!_isClosed) {
        emit(state.copyWith(status: AnalyticsStatus.error));
      }
    }
  }

  void updateDate(DateTime date) {
    if (_isClosed) return;
    final car = carCubit.state.carId;
    emit(state.copyWith(selectedDate: date));
    _reloadForCar(car);
  }

  StreamSubscription? _sub;
  void clear() {
    _sub?.cancel();
    _sub = null;
    emit(AnalyticsState.initial());
  }

  void stopListeningToCar() {
    if (_isClosed) return;
    _carSub.cancel();
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _carSub.cancel();
    return super.close();
  }

  Future<void> loadForCurrentCar() async {
    if (_isClosed) return;

    final carId = carCubit.state.carId;
    if (carId.isEmpty) return;

    await _reloadForCar(carId);
  }
}
