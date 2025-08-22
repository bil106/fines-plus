import 'package:core_cubit/cubit/fines_state.dart';
import 'package:core_repository/fines_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinesCubit extends Cubit<FinesState> {
  final FinesRepository repository;

  FinesCubit(this.repository) : super(FinesInitial());

  Future<void> checkFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
  }) async {
    emit(FinesLoading());
    try {
      final fines = await repository.fetchFines(
        carNumber: carNumber,
        docSeries: docSeries,
        docNumber: docNumber,
      );
      if (fines.isEmpty) {
        emit(FinesEmpty());
      } else {
        emit(FinesLoaded(fines));
      }
    } catch (e) {
      emit(FinesError(e.toString()));
    }
  }
}
