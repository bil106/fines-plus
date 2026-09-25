import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

/// 1 USD = 40 UAH.
class _Currency extends Fake implements CurrencyService {
  @override
  Future<void> get ready => Future.value();

  @override
  double toUah(double amount, String? currency) =>
      currency == 'USD' ? amount * 40 : amount;
}

class _MaintenanceStub extends Cubit<MaintenanceState> implements MaintenanceCubit {
  _MaintenanceStub(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('monthly total converts each record from its own currency', () async {
    final now = DateTime.now();
    final maintenance = _MaintenanceStub(
      MaintenanceState(
        fuelRecords: [
          FuelRecord(
            fuelType: 'Electric',
            volume: 10,
            cost: 1.5,
            date: now,
            mileage: 1000,
            currency: 'USD',
          ),
        ],
        serviceRecords: [
          ServiceRecord(
            serviceName: 'Oil',
            cost: 400,
            date: DateFormat('dd.MM.yyyy').format(now),
            mileage: 1000,
            currency: 'UAH',
          ),
        ],
      ),
    );
    final cubit = StatisticsCubit(maintenance, currencyService: _Currency());
    addTearDown(cubit.close);
    addTearDown(maintenance.close);

    final state = await cubit.stream.firstWhere((s) => !s.loading);

    // 1.50 USD -> 60 UAH, plus 400 UAH - not 1.5 + 400.
    expect(state.expenseStats.total, 460);
  });
}
