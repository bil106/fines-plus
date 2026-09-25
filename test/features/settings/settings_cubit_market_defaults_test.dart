import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppConfig _config(String market) => AppConfig(
  brandName: 'Test',
  primaryColorHex: '#1976D2',
  logoAssetPath: '',
  supportEmail: '',
  phoneNumber: '',
  viberNumber: '',
  market: market,
);

/// Creates the cubit and waits for its async SharedPreferences load.
Future<SettingsState> _settingsFor(String market) async {
  final cubit = SettingsCubit(currencyService: CurrencyService(), config: _config(market));
  addTearDown(cubit.close);
  await cubit.stream.first;
  return cubit.state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('UA market defaults to Ukrainian, km, UAH, l/100km', () async {
    final state = await _settingsFor('UA');
    expect(state.locale.languageCode, 'uk');
    expect(state.unit, 'km');
    expect(state.currency, 'UAH');
    expect(state.fuelConsumptionUnit, 'l/100km');
  });

  test('US market defaults to English, miles, USD, mpg', () async {
    final state = await _settingsFor('US');
    expect(state.locale.languageCode, 'en');
    expect(state.unit, 'mil');
    expect(state.currency, 'USD');
    expect(state.fuelConsumptionUnit, 'mpg');
  });

  test('other markets (e.g. ES) default to km, EUR, l/100km', () async {
    final state = await _settingsFor('ES');
    expect(state.unit, 'km');
    expect(state.currency, 'EUR');
    expect(state.fuelConsumptionUnit, 'l/100km');
  });

  test('values the user already picked win over market defaults', () async {
    SharedPreferences.setMockInitialValues({
      'unit': 'km',
      'currency': 'EUR',
      'fuelConsumptionUnit': 'l/100km',
      'locale': 'uk',
    });
    final state = await _settingsFor('US');
    expect(state.locale.languageCode, 'uk');
    expect(state.unit, 'km');
    expect(state.currency, 'EUR');
    expect(state.fuelConsumptionUnit, 'l/100km');
  });
}
