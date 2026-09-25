import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/features/history/domain/history_repository.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _CarStub extends Cubit<CarState> implements CarCubit {
  _CarStub(this.config) : super(const CarState(carId: 'car', carNumber: 'ABC1234'));

  @override
  final AppConfig config;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RepositoryStub implements HistoryRepository {
  int queries = 0;

  @override
  Stream<List<FineHistory>> getHistory(String carNumber) {
    queries++;
    return const Stream.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('brands without the fines check never query fines history', () async {
    final car = _CarStub(
      const AppConfig(
        brandName: 'Test',
        primaryColorHex: '#1976D2',
        logoAssetPath: '',
        supportEmail: '',
        phoneNumber: '',
        viberNumber: '',
        market: 'US',
        finesCheckEnabled: false,
      ),
    );
    final repository = _RepositoryStub();
    final cubit = HistoryCubit(repository: repository, carCubit: car);
    addTearDown(cubit.close);
    addTearDown(car.close);

    car.emit(const CarState(carId: 'car', carNumber: 'XYZ9876'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<HistoryEmpty>());
    expect(repository.queries, 0);
  });
}
