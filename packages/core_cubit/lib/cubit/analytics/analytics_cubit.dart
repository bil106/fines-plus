
import 'package:core_repository/analytics_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final AnalyticsRepository repository;
  

  AnalyticsCubit({required this.repository}) : super(AnalyticsState.initial());

  void updateDate(DateTime date) async {
    emit(state.copyWith(status: AnalyticsStatus.loading, selectedDate: date));
    try {
      final data = await repository.getAnalytics(date);
      emit(state.copyWith(
        status: AnalyticsStatus.loaded,
        fuelLiters: data.fuelLiters.toString(),
        fuelCost: data.fuelCost,
        mileage: data.mileage,
      ));
    } catch (e) {
      emit(state.copyWith(status: AnalyticsStatus.error));
    }
  }
}
