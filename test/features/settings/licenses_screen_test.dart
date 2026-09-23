import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/features/settings/presentation/screens/licenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compact licenses page opens offline notices and library list', (
    tester,
  ) async {
    final router = RootStackRouter.build(
      routes: [
        AutoRoute(page: LicensesRoute.page, initial: true),
        AutoRoute(page: VehicleDataLicenseRoute.page),
        AutoRoute(page: LibraryLicensesRoute.page),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      RepositoryProvider<AppConfig>.value(
        value: const AppConfig(
          brandName: 'Test brand',
          primaryColorHex: '#007AFF',
          logoAssetPath: '',
          supportEmail: '',
          phoneNumber: '',
          viberNumber: '',
        ),
        child: MaterialApp.router(
          routerConfig: router.config(),
          theme: ThemeData(
            splashFactory: NoSplash.splashFactory,
            extensions: const [
              AppBrandTheme(
                surfaceBg: Colors.white,
                surfaceBorder: Colors.grey,
                divider: Colors.grey,
                alertBg: Colors.white,
                alertBorder: Colors.grey,
                alertFg: Colors.black,
                displayTextStyle: TextStyle(),
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
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ліцензії та джерела'), findsOneWidget);
    expect(find.byType(LicensePage), findsNothing);
    await tester.tap(find.text('Джерела та умови використання'));
    await tester.pumpAndSettle();
    expect(find.byType(VehicleDataLicenseScreen), findsOneWidget);
    final text = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .data!;
    expect(text, contains('Vehicle data by VehiclesDB'));
    expect(text, contains('Ukraine'));
    expect(text, contains('Changes:'));
    await router.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Переглянути ліцензії'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.text('Test brand'), findsOneWidget);
    await router.maybePop();
    await tester.pumpAndSettle();
    expect(find.byType(LicensesScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
