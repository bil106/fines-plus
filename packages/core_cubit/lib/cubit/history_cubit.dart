import 'dart:async';

import 'package:core_cubit/cubit/history_state.dart';
import 'package:core_repository/history_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repository;
  StreamSubscription? _subscription;

  HistoryCubit({required this.repository}) : super(HistoryLoading());

  void loadHistory(String carNumber) {
    _subscription?.cancel();
    _subscription = repository.getHistory(carNumber).listen(
      (items) {
        debugPrint('HistoryCubit: received ${items.length} items');
        if (items.isEmpty) {
          emit(HistoryEmpty());
        } else {
          emit(HistoryLoaded(items));
        }
      },
      onError: (e, st) {
        debugPrint('HistoryCubit stream error: $e\n$st');
        emit(HistoryError(e.toString()));
      },
    );
  }

  Future<void> addHistory({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required List<Map<String, dynamic>> fines,
  }) async {
    await repository.addToHistory(
      carNumber: carNumber,
      docSeries: docSeries,
      docNumber: docNumber,
      fines: fines,
    );
    loadHistory(carNumber);
  }

  Future<void> deleteAll(String carNumber) async {
    await repository.deleteAll(carNumber);
    emit(HistoryEmpty());
  }

  Future<void> deleteSingle(String id) async {
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
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
