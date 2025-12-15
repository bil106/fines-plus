import 'dart:async';

import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_unauthorized.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/foundation.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repository;
  final CarCubit carCubit;
  StreamSubscription? _carSubscription;
  StreamSubscription? _historySubscription;
  HistoryCubit({required this.repository, required this.carCubit}) : super(HistoryInitial()) {
    _carSubscription = carCubit.stream.listen((carState) {
      if (carState.carNumber.isNotEmpty) {
        loadHistory(carState.carNumber);
      }
    });
  }

  void loadHistory(String carNumber) {
    _historySubscription?.cancel();

    emit(HistoryLoading());
    try {
      _historySubscription = repository
          .getHistory(carNumber)
          .listen(
            (items) {
              if (items.isEmpty) {
                emit(HistoryEmpty());
              } else {
                emit(HistoryLoaded(items));
              }
            },
            onError: (e, st) {
              debugPrint('HistoryCubit stream error: $e\n$st');

              if (e.toString().contains("User is not signed in")) {
                emit(HistoryUnauthorized());
              } else if (e is FirebaseException && e.code == 'failed-precondition') {
                emit(HistoryError(S.current.history_unavailable));
              } else {
                emit(HistoryError(e.toString()));
              }
            },
          );
    } catch (e) {
      if (e.toString().contains("User is not signed in")) {
        emit(HistoryUnauthorized());
      } else {
        emit(HistoryError(e.toString()));
      }
    }
  }

  Future<void> addHistory({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required List<Map<String, dynamic>> fines,
  }) async {
    try {
      await repository.addToHistory(carNumber: carNumber, docSeries: docSeries, docNumber: docNumber, fines: fines);
      loadHistory(carNumber);
    } catch (e, st) {
      debugPrint('HistoryCubit addHistory error: $e\n$st');
      if (e.toString().contains("User is not signed in")) {
        emit(HistoryUnauthorized());
      } else if (e is FirebaseException && e.code == 'failed-precondition') {
        emit(HistoryError(S.current.history_unavailable));
      } else {
        emit(HistoryError(e.toString()));
      }
    }
  }

  Future<void> deleteAll(String carNumber) async {
    try {
      await repository.deleteAll(carNumber);
      emit(HistoryEmpty());
    } catch (e, st) {
      debugPrint('HistoryCubit deleteAll error: $e\n$st');
      if (e.toString().contains("User is not signed in")) {
        emit(HistoryUnauthorized());
      } else {
        emit(HistoryError(e.toString()));
      }
    }
  }

  Future<void> deleteSingle(String id) async {
    try {
      await repository.deleteSingle(id);

      if (state is HistoryLoaded) {
        final current = (state as HistoryLoaded).history;
        final updated = current.where((item) => item.id != id).toList();

        if (updated.isEmpty) {
          emit(HistoryEmpty());
        } else {
          emit(HistoryLoaded(updated));
        }
      }
    } catch (e, st) {
      debugPrint('HistoryCubit deleteSingle error: $e\n$st');
      if (e.toString().contains("User is not signed in")) {
        emit(HistoryUnauthorized());
      } else {
        emit(HistoryError(e.toString()));
      }
    }
  }

  void clear() {
    _historySubscription?.cancel();
    _historySubscription = null;
    emit(HistoryInitial());
  }


  @override
  Future<void> close() {
    _carSubscription?.cancel();
    _historySubscription?.cancel();
    return super.close();
  }
}
