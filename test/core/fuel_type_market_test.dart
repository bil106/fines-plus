import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/plate_market.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/extensions/fuel_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Labels of [fuels] as `fuelTypeLabel` renders them for [market].
Future<List<String>> _labels(WidgetTester tester, String market, List<FuelType> fuels, {String locale = 'en'}) async {
  late List<String> labels;
  await tester.pumpWidget(
    Provider<AppConfig>.value(
      value: AppConfig(
        brandName: 'Test',
        primaryColorHex: '#1976D2',
        logoAssetPath: '',
        supportEmail: '',
        phoneNumber: '',
        viberNumber: '',
        market: market,
      ),
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) {
            labels = [for (final fuel in fuels) fuelTypeLabel(context, fuel.name)];
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return labels;
}

void main() {
  group('fuelTypesFor', () {
    test('UA keeps the existing picker', () {
      expect(fuelTypesFor(PlateMarket.ua), [
        FuelType.Ai95,
        FuelType.Ai92,
        FuelType.DIESEl,
        FuelType.LPG,
        FuelType.Electric,
      ]);
    });

    test('Americas offer only the grades sold there, cheapest first', () {
      expect(fuelTypesFor(PlateMarket.us).first, FuelType.Ai92);
      expect(fuelTypesFor(PlateMarket.mx), isNot(contains(FuelType.Ai95)));
      expect(fuelTypesFor(PlateMarket.ar), isNot(contains(FuelType.Ai92)));
      for (final market in [PlateMarket.us, PlateMarket.mx, PlateMarket.ar]) {
        expect(fuelTypesFor(market), isNot(contains(FuelType.LPG)));
        expect(fuelTypesFor(market), isNot(contains(FuelType.Ai95Plus)));
      }
    });
  });

  testWidgets('US names octane grades Regular / Midgrade / Premium', (tester) async {
    final labels = await _labels(tester, 'US', fuelTypesFor(PlateMarket.us));
    expect(labels, ['Regular', 'Midgrade', 'Premium', 'Diesel', 'Electric']);
  });

  testWidgets('Mexico and Argentina use their local grade names in Spanish', (tester) async {
    expect(await _labels(tester, 'MX', fuelTypesFor(PlateMarket.mx), locale: 'es'), [
      'Magna',
      'Premium',
      'Diésel',
      'Eléctrico',
    ]);
    expect(await _labels(tester, 'AR', fuelTypesFor(PlateMarket.ar), locale: 'es'), [
      'Súper',
      'Premium',
      'Diésel',
      'Eléctrico',
    ]);
  });

  testWidgets('UA keeps AI-92/95 names', (tester) async {
    final labels = await _labels(tester, 'UA', [FuelType.Ai95, FuelType.Ai92], locale: 'en');
    expect(labels, ['AI-95', 'AI-92']);
  });
}
