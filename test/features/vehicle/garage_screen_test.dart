import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
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
        ],
        child: MaterialApp(
          theme: ThemeData(
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

  testWidgets(
    'card fits narrow display with large text and retains edit/delete menu',
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
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text(S.current.edit), findsOneWidget);
      expect(find.text(S.current.delete), findsOneWidget);
      await tester.tap(find.text(S.current.delete));
      await tester.pumpAndSettle();
      expect(find.text(S.current.garage_delete_confirm_title), findsOneWidget);
      await tester.tap(find.text(S.current.cancel));
      await tester.pumpAndSettle();
      expect(find.text('AI1234IO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
