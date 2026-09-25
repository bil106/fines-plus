import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:fines_plus/features/vehicle/presentation/screens/garage_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class GarageStub extends Cubit<GarageState> implements GarageCubit {
  GarageStub(super.state);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class CarStub extends Cubit<CarState> implements CarCubit {
  CarStub() : super(const CarState(carId: 'car'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MaintenanceStub extends Cubit<MaintenanceState>
    implements MaintenanceCubit {
  MaintenanceStub() : super(const MaintenanceState());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SettingsStub extends Cubit<SettingsState> implements SettingsCubit {
  SettingsStub()
    : super(
        SettingsState(
          unit: 'км',
          currency: 'UAH',
          locale: const Locale('uk'),
          fuelConsumptionUnit: 'l',
        ),
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> open(
    WidgetTester tester, {
    List<CarInfoModel> cars = const [],
    VoidCallback? onContinue,
  }) async {
    final garage = GarageStub(
      GarageState(cars: cars, activeCarId: 'car', isLoading: false),
    );
    final car = CarStub();
    final maintenance = MaintenanceStub();
    final settings = SettingsStub();
    addTearDown(garage.close);
    addTearDown(car.close);
    addTearDown(maintenance.close);
    addTearDown(settings.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<GarageCubit>.value(value: garage),
          BlocProvider<CarCubit>.value(value: car),
          BlocProvider<MaintenanceCubit>.value(value: maintenance),
          BlocProvider<SettingsCubit>.value(value: settings),
          RepositoryProvider<AppConfig>.value(
            value: const AppConfig(
              brandName: 'Test brand',
              primaryColorHex: '#007AFF',
              logoAssetPath: '',
              supportEmail: '',
              phoneNumber: '',
              viberNumber: '',
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
            // The default InkSparkle splash loads a shader asset that can't be
            // decoded in the test environment.
            splashFactory: NoSplash.splashFactory,
            extensions: const [
              AppBrandTheme(
                surfaceBg: Color(0xFFF6F4ED),
                surfaceBorder: Color(0xFFE5DFD0),
                divider: Colors.grey,
                alertBg: Colors.white,
                alertBorder: Colors.grey,
                alertFg: Colors.black,
                displayTextStyle: TextStyle(fontWeight: FontWeight.w800),
                moneyTextStyle: TextStyle(),
              ),
            ],
          ),
          locale: const Locale('uk'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: GarageScreen(onContinue: onContinue),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty garage allows continuing without adding a car', (
    tester,
  ) async {
    var continued = false;
    await open(tester, onContinue: () => continued = true);
    expect(find.text('Гараж'), findsOneWidget);
    expect(find.text('0 авто'), findsOneWidget);
    expect(find.text(S.current.garage_empty_add_car), findsOneWidget);
    await tester.tap(find.text('Продовжити'));
    expect(continued, isTrue);
  });

  testWidgets('the blank first-launch car is not listed or counted', (tester) async {
    await open(
      tester,
      cars: const [
        CarInfoModel(carId: 'blank', carNumber: '', techPassport: '', ownerId: 'owner'),
        CarInfoModel(carId: 'car', carNumber: 'AI1234IO', techPassport: '', ownerId: 'owner', make: 'Ford'),
      ],
    );
    expect(find.text('1 авто'), findsOneWidget);
    expect(find.text('Ford'), findsOneWidget);
    expect(find.text(S.current.auto), findsNothing);
  });

  testWidgets('card title shows make and model', (tester) async {
    await open(
      tester,
      cars: const [
        CarInfoModel(
          carId: 'car',
          carNumber: 'AI1234IO',
          techPassport: '',
          ownerId: 'owner',
          make: 'Ford',
          model: 'Focus',
        ),
      ],
    );
    expect(find.text('Ford Focus'), findsOneWidget);
  });

  testWidgets(
    'card fits narrow display with large text and opens the edit sheet on long-press',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await open(
        tester,
        cars: const [
          CarInfoModel(
            carId: 'car',
            carNumber: 'AI1234IO',
            techPassport: '',
            ownerId: 'owner',
            make: 'Skoda Octavia A7',
          ),
        ],
      );
      expect(find.text('1 авто'), findsOneWidget);
      expect(find.text('Skoda Octavia A7'), findsOneWidget);
      expect(find.text('AI1234IO'), findsOneWidget);
      expect(find.text('Продовжити'), findsNothing);
      expect(tester.takeException(), isNull);
      // The card's own edit/delete popup menu was dropped in favor of the
      // mockup's plain card (see settings_screen.dart's car row for the
      // remaining edit/delete UI) - editing here is a long-press that opens
      // the same car-details sheet the "+" FAB uses. Checking the callback
      // is wired (rather than actually triggering it) avoids depending on
      // showCarFormSheet's own make-dropdown/image-picker setup here.
      final inkWell = tester.widget<InkWell>(
        find
            .ancestor(of: find.text('AI1234IO'), matching: find.byType(InkWell))
            .first,
      );
      expect(inkWell.onLongPress, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  Future<void> openEditSheet(WidgetTester tester, {String model = ''}) async {
    await open(
      tester,
      cars: [
        CarInfoModel(
          carId: 'car',
          carNumber: 'AI1234IO',
          techPassport: '',
          ownerId: 'owner',
          make: 'Ford',
          model: model,
        ),
      ],
    );
    await tester.longPress(find.text('AI1234IO'));
    await tester.pumpAndSettle();
  }

  // Make is the first dropdown in the sheet, model the second.
  Finder makeDropdown() => find.byType(DropdownButtonFormField<String>).at(0);
  Finder modelDropdown() => find.byType(DropdownButtonFormField<String>).at(1);

  Future<void> pick(WidgetTester tester, Finder dropdown, String item) async {
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  testWidgets('model is picked from the selected make\'s list', (
    tester,
  ) async {
    await openEditSheet(tester);
    // Near the top of Ford's list - the menu only builds visible items.
    await pick(tester, modelDropdown(), 'Puma');
    expect(
      find.descendant(of: modelDropdown(), matching: find.text('Puma')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing the make resets the model and swaps the list', (
    tester,
  ) async {
    await openEditSheet(tester, model: 'Focus');
    await pick(tester, makeDropdown(), 'Škoda');
    expect(
      find.descendant(of: modelDropdown(), matching: find.text('Focus')),
      findsNothing,
    );

    await pick(tester, modelDropdown(), 'Octavia');
    expect(
      find.descendant(of: modelDropdown(), matching: find.text('Octavia')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a hand-typed model saved earlier stays selected', (
    tester,
  ) async {
    await openEditSheet(tester, model: 'Focus RS Custom');
    expect(
      find.descendant(
        of: modelDropdown(),
        matching: find.text('Focus RS Custom'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
