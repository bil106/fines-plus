import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_bottom_sheet.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Maintenance extends Cubit<MaintenanceState> implements MaintenanceCubit {
  // getLastKnownMileage() is an extension over the records in the state, so
  // the previous mileage is seeded as a record rather than overridden.
  _Maintenance()
    : super(
        MaintenanceState(
          serviceRecords: [
            ServiceRecord(
              serviceName: 'Previous service',
              cost: 0,
              date: '01.01.2026',
              mileage: 127900,
              currency: 'UAH',
            ),
          ],
        ),
      );
  List<ServiceRecord>? saved;
  @override
  Future<void> addServiceRecords(List<ServiceRecord> records) async =>
      saved = records;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Currency extends Fake implements CurrencyService {
  @override
  double convert(
    double amount,
    String toCurrency, {
    required String fromCurrency,
  }) {
    if (toCurrency == fromCurrency) return amount;
    return toCurrency == 'UAH' ? amount * 40 : amount / 40;
  }
}

class _Settings extends Cubit<SettingsState> implements SettingsCubit {
  _Settings(String currency)
    : super(
        SettingsState(
          unit: 'km',
          currency: currency,
          locale: const Locale('uk'),
          fuelConsumptionUnit: 'l/100km',
        ),
      );
  @override
  CurrencyService get currencyService => _Currency();
  @override
  double convertFromUAH(double amount) =>
      currencyService.convert(amount, state.currency, fromCurrency: 'UAH');
  @override
  double convertToUAH(double amount) =>
      currencyService.convert(amount, 'UAH', fromCurrency: state.currency);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          (call) async =>
              call.method == 'isLocationServiceEnabled' ? false : null,
        );
  });

  Future<_Maintenance> openSheet(
    WidgetTester tester, {
    String currency = 'UAH',
  }) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final maintenance = _Maintenance();
    final settings = _Settings(currency);
    final key = GlobalKey<ServiceScreenState>();
    addTearDown(maintenance.close);
    addTearDown(settings.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MaintenanceCubit>.value(value: maintenance),
          BlocProvider<SettingsCubit>.value(value: settings),
        ],
        child: MaterialApp(
          locale: const Locale('uk'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: ThemeData(
            // The default InkSparkle splash loads a shader asset that can't be
            // decoded in the test environment.
            splashFactory: NoSplash.splashFactory,
            extensions: const [
              AppBrandTheme(
                surfaceBg: Color(0xFFF5F3ED),
                surfaceBorder: Color(0xFFE6E1D2),
                divider: Color(0xFFE7E3D6),
                alertBg: Colors.red,
                alertBorder: Colors.red,
                alertFg: Colors.red,
                displayTextStyle: TextStyle(),
                moneyTextStyle: TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AppBottomSheet.show(
                  context,
                  title: S.of(context).maintenance,
                  saveLabel: S.of(context).save,
                  onSave: () => key.currentState?.save(),
                  contentBuilder: (_) => ServiceScreen(
                    key: key,
                    embedded: true,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return maintenance;
  }

  Finder nameFields() => find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
        widget.controller != null &&
        widget.decoration?.hintText == S.current.select_a_service,
  );
  Finder priceFields() => find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
            widget.decoration?.suffixText?.contains('UAH') == true ||
        widget is TextField &&
            widget.decoration?.suffixText?.contains('USD') == true,
  );

  testWidgets(
    'work prices total correctly, removal updates total, save retains details',
    (tester) async {
      final maintenance = await openSheet(tester);
      expect(
        tester.widget<TextField>(find.byWidgetPredicate((widget) =>
            widget is TextField && widget.decoration?.hintText == S.current.enter_mileage))
            .controller!.text,
        '127 900',
      );
      await tester.enterText(nameFields().first, 'Custom oil change');
      await tester.enterText(priceFields().first, '850');
      await tester.pumpAndSettle();
      expect(find.text('850 UAH'), findsOneWidget);
      await tester.tap(find.text(S.current.service_add_work));
      await tester.pumpAndSettle();
      await tester.enterText(nameFields().last, 'Custom filter');
      await tester.enterText(priceFields().last, '250');
      await tester.pumpAndSettle();
      expect(find.text('1100 UAH'), findsOneWidget);
      await tester.tap(find.byTooltip(S.current.delete).first);
      await tester.pumpAndSettle();
      expect(find.text('250 UAH'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(S.current.save));
      await tester.pumpAndSettle();
      expect(maintenance.saved, hasLength(1));
      expect(maintenance.saved!.single.serviceName, 'Custom filter');
      expect(maintenance.saved!.single.cost, 250);
      expect(maintenance.saved!.single.currency, 'UAH');
      expect(maintenance.saved!.single.mileage, 127900);
    },
  );

  testWidgets('prices take cents in display currency and save in UAH', (
    tester,
  ) async {
    final maintenance = await openSheet(tester, currency: 'USD');
    await tester.enterText(nameFields().first, 'Custom work');
    // Price fields take up to two decimals; a typed comma becomes a dot.
    await tester.enterText(priceFields().first, '12,50');
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: priceFields().first, matching: find.text('12.50')),
      findsOneWidget,
    );
    expect(find.text('13 USD'), findsOneWidget);
    await tester.tap(find.text(S.current.save));
    await tester.pumpAndSettle();
    expect(maintenance.saved!.single.cost, 500);
    expect(maintenance.saved!.single.currency, 'UAH');
  });

  testWidgets('sheet remains usable above keyboard and rejects missing price', (
    tester,
  ) async {
    final maintenance = await openSheet(tester);
    await tester.enterText(nameFields().first, 'Custom work');
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getBottomLeft(find.text(S.current.save)).dy, lessThan(500));
    await tester.tap(find.text(S.current.save));
    await tester.pumpAndSettle();
    expect(maintenance.saved, isNull);
    expect(find.text(S.current.service_invalid_price), findsOneWidget);
  });
}
