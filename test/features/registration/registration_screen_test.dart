import 'package:auto_route/auto_route.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:fines_plus/features/registration/presentation/screens/registration_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Minimal stand-in for the real per-flavor config a `Provider<AppConfig>`
/// supplies in the app (see lib/app/app.dart) - RegistrationScreen reads
/// primaryColorHex for its button/link accent (see registration_screen.dart).
const _testConfig = AppConfig(
  brandName: 'Test',
  primaryColorHex: '#1976D2',
  logoAssetPath: '',
  supportEmail: '',
  phoneNumber: '',
  viberNumber: '',
);

class RegistrationStub extends Cubit<RegistrationState>
    implements RegistrationCubit {
  RegistrationStub() : super(const RegistrationState());
  String? submittedPassword;
  int submissions = 0;
  void showErrors({String? email, String? general}) =>
      emit(state.copyWith(emailError: email, error: general));
  @override
  Future<Map<String, String>> loadCredentials() async => {
    'email': '',
    'password': '',
  };
  @override
  void toggleLoginMode() =>
      emit(state.copyWith(isExistingUser: !state.isExistingUser));
  @override
  Future<void> register(String email, String password) async {
    submissions++;
    submittedPassword = password;
    emit(state.copyWith(isLoading: true));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class OnboardingTestRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: OnboardingRoute.page, initial: true),
    AutoRoute(page: RegistrationRoute.page),
  ];
}

/// Pumps the onboarding flow (onboarding -> registration) for [config].
Future<OnboardingTestRouter> _openOnboarding(
  WidgetTester tester,
  AppConfig config,
) async {
  PackageInfo.setMockInitialValues(
    appName: 'Fines',
    packageName: 'com.finesplus',
    version: '1',
    buildNumber: '1',
    buildSignature: '',
  );
  final router = OnboardingTestRouter();
  final cubit = RegistrationStub();
  addTearDown(router.dispose);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    Provider<AppConfig>.value(
      value: config,
      child: BlocProvider<RegistrationCubit>.value(
        value: cubit,
        child: MaterialApp.router(
          routerConfig: router.config(),
          // The onboarding hero illustrations loop forever while their
          // slide is active, so pumpAndSettle would never settle -
          // "reduce motion" turns those loops off, as it does on devices.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          theme: ThemeData(
            // The default InkSparkle splash loads a shader asset that can't be
            // decoded in the test environment.
            splashFactory: NoSplash.splashFactory,
            extensions: const [
              AppBrandTheme(
                surfaceBg: Color(0xFFF6F4ED),
                surfaceBorder: Color(0xFFE5DFD0),
                divider: Color(0xFFE5DFD0),
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
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);
  Future<RegistrationStub> open(
    WidgetTester tester,
    TargetPlatform platform,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    final cubit = RegistrationStub();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      Provider<AppConfig>.value(
        value: _testConfig,
        child: BlocProvider<RegistrationCubit>.value(
          value: cubit,
          child: MaterialApp(
            theme: ThemeData(
              // The default InkSparkle splash loads a shader asset that can't be
              // decoded in the test environment.
              splashFactory: NoSplash.splashFactory,
              extensions: const [
                AppBrandTheme(
                  surfaceBg: Color(0xFFF6F4ED),
                  surfaceBorder: Color(0xFFE5DFD0),
                  divider: Color(0xFFE5DFD0),
                  alertBg: Colors.white,
                  alertBorder: Colors.grey,
                  alertFg: Colors.black,
                  displayTextStyle: TextStyle(),
                  moneyTextStyle: TextStyle(),
                ),
              ],
            ),
            locale: const Locale('uk'),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const RegistrationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('registration is explicit and Apple appears only on iOS', (
    tester,
  ) async {
    final cubit = await open(tester, TargetPlatform.iOS);
    expect(find.text('Реєстрація'), findsOneWidget);
    expect(find.byTooltip('Apple'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'existing@example.com',
    );
    await tester.pump(const Duration(seconds: 1));
    expect(cubit.state.isExistingUser, isFalse);
    await tester.tap(find.text(S.current.already_have_account));
    await tester.pumpAndSettle();
    expect(cubit.state.isExistingUser, isTrue);
    expect(find.text(S.current.login), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'validates empty input and preserves password spaces; locks other login actions',
    (tester) async {
      final cubit = await open(tester, TargetPlatform.android);
      expect(find.byTooltip('Apple'), findsNothing);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(cubit.submissions, 0);
      expect(find.text(S.current.enter_email), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, ' password ');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(cubit.submittedPassword, ' password ');
      expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.facebook))
            .onPressed,
        isNull,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('server errors wrap below inputs without clipping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cubit = await open(tester, TargetPlatform.android);
    const networkError =
        'A network error (such as timeout, interrupted connection or unreachable host) has occurred. Please try again.';
    cubit.showErrors(email: 'Email already in use', general: networkError);
    await tester.pumpAndSettle();
    for (final field in find.byType(TextFormField).evaluate()) {
      expect(
        find.descendant(
          of: find.byWidget(field.widget),
          matching: find.byType(ClipRRect),
        ),
        findsNothing,
      );
    }
    final error = find.text(networkError);
    expect(error, findsOneWidget);
    expect(tester.getSize(error).height, greaterThan(30));
    final inputs = find.byType(EditableText);
    expect(
      tester.getTopLeft(find.text('Email already in use')).dy,
      greaterThan(tester.getBottomLeft(inputs.first).dy),
    );
    expect(
      tester.getTopLeft(error).dy,
      greaterThan(tester.getBottomLeft(inputs.last).dy),
    );
    expect(
      tester.getBottomLeft(error).dy,
      lessThan(tester.getTopLeft(find.byType(FilledButton)).dy),
    );
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'small screen with keyboard remains scrollable without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester, TargetPlatform.iOS);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Apple'));
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    },
  );
  testWidgets(
    'four onboarding pages lead to registration and back returns to page four',
    (tester) async {
      final router = await _openOnboarding(tester, _testConfig);
      for (var i = 0; i < 3; i++) {
        await tester.drag(find.byType(PageView), const Offset(-800, 0));
        await tester.pumpAndSettle();
      }
      expect(find.text(S.current.analytics), findsOneWidget);
      final lastButton = find.widgetWithText(
        ElevatedButton,
        S.current.of_course,
      );
      await tester.ensureVisible(lastButton);
      await tester.tap(lastButton);
      await tester.pumpAndSettle();
      expect(router.current.name, RegistrationRoute.name);
      expect(find.text('Реєстрація'), findsOneWidget);
      await router.maybePop();
      await tester.pumpAndSettle();
      expect(find.text(S.current.analytics), findsOneWidget);
    },
  );

  testWidgets(
    'without the fines check onboarding has three pages and no fines slide',
    (tester) async {
      final router = await _openOnboarding(
        tester,
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
      for (var i = 0; i < 2; i++) {
        expect(find.text(S.current.fines_control), findsNothing);
        await tester.drag(find.byType(PageView), const Offset(-800, 0));
        await tester.pumpAndSettle();
      }
      expect(find.text(S.current.fines_control), findsNothing);
      expect(find.text(S.current.analytics), findsOneWidget);
      final lastButton = find.widgetWithText(
        ElevatedButton,
        S.current.of_course,
      );
      await tester.ensureVisible(lastButton);
      await tester.tap(lastButton);
      await tester.pumpAndSettle();
      expect(router.current.name, RegistrationRoute.name);
    },
  );
}
