import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _Settings extends Cubit<SettingsState> implements SettingsCubit {
  _Settings(String fuelUnit)
      : super(SettingsState(
          unit: 'mil',
          currency: 'USD',
          locale: const Locale('en'),
          fuelConsumptionUnit: fuelUnit,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('mpg with no consumption yet is 0, not Infinity', () {
    final settings = _Settings('mpg');
    addTearDown(settings.close);
    expect(UnitStream(settings).convertFuel(0), 0);
    expect(UnitStream(settings).convertFuel(10), closeTo(23.52, 0.01));
  });

  test('l/100km is passed through', () {
    final settings = _Settings('l/100km');
    addTearDown(settings.close);
    expect(UnitStream(settings).convertFuel(0), 0);
    expect(UnitStream(settings).convertFuel(7.5), 7.5);
  });
}
