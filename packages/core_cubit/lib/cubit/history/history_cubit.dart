import 'dart:async';

import 'package:core_cubit/cubit/history/history_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/history_repository.dart';
import 'package:firebase_core/firebase_core.dart';
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

      
        if (e is FirebaseException && e.code == 'failed-precondition') {
          emit(HistoryError(
             S.current.history_unavailable,
          ));
        } else {
          emit(HistoryError(e.toString()));
        }
      },
    );
  }

  Future<void> addHistory({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required List<Map<String, dynamic>> fines,
  }) async {
    try {
      await repository.addToHistory(
        carNumber: carNumber,
        docSeries: docSeries,
        docNumber: docNumber,
        fines: fines,
      );
      loadHistory(carNumber);
    } catch (e, st) {
      debugPrint('HistoryCubit addHistory error: $e\n$st');

      if (e is FirebaseException && e.code == 'failed-precondition') {
        emit(HistoryError(
          S.current.history_unavailable,
        ));
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
      emit(HistoryError(e.toString()));
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
      emit(HistoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
