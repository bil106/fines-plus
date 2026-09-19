import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/features/fines/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_cubit.dart';
import 'package:fines_plus/features/history/presentation/cubit/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class HistoryStub extends Cubit<HistoryState> implements HistoryCubit {
  HistoryStub(super.state);
  int payments = 0;
  @override
  Future<void> markFineAsPaid(
    String historyId,
    String fineId,
    bool paid,
  ) async {
    payments++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<HistoryStub> open(
    WidgetTester tester, {
    bool demo = true,
    HistoryState? state,
  }) async {
    final cubit = HistoryStub(state ?? HistoryEmpty());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      BlocProvider<HistoryCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const [
              AppBrandTheme(
                surfaceBg: Color(0xFFF5F3ED),
                surfaceBorder: Color(0xFFE6E1D2),
                divider: Color(0xFFE7E3D6),
                alertBg: Color(0xFFFBE1E1),
                alertBorder: Color(0xFFF3B9B9),
                alertFg: Color(0xFFB23A3E),
                displayTextStyle: TextStyle(),
                moneyTextStyle: TextStyle(fontWeight: FontWeight.w700),
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
          home: FinesScreen(showDemo: demo),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets(
    'preview has unpaid and paid fines; pay and refresh never write live data',
    (tester) async {
      final cubit = await open(tester);
      expect(find.text(S.current.fines_demo_speed), findsOneWidget);
      expect(find.text(S.current.fines_demo_parking), findsOneWidget);
      expect(find.text('255 UAH'), findsNWidgets(2));
      expect(find.text(S.current.paid_fines_section), findsOneWidget);
      await tester.tap(find.text(S.current.pay));
      await tester.pump();
      expect(cubit.payments, 0);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(cubit.payments, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('real empty history shows no fabricated fines', (tester) async {
    await open(tester, demo: false);
    expect(find.text(S.current.no_fines), findsOneWidget);
    expect(find.text(S.current.fines_demo_label), findsNothing);
    expect(find.text(S.current.pay), findsNothing);
  });

  testWidgets('real history preserves existing payment callback', (
    tester,
  ) async {
    final cubit = await open(
      tester,
      demo: false,
      state: HistoryLoaded([
        FineHistory(
          id: 'real',
          userId: 'user',
          carNumber: 'AA1234AA',
          docSeries: '',
          docNumber: '',
          checkedAt: DateTime(2026, 9, 1),
          fines: [
            {
              'id': 'fine',
              'amount': 340,
              'description': 'Real fine',
              'date': '2026-08-01',
            },
          ],
        ),
      ]),
    );
    expect(find.text('340 UAH'), findsNWidgets(2));
    await tester.tap(find.text(S.current.pay));
    await tester.pump();
    expect(cubit.payments, 1);
  });

  testWidgets('preview remains scrollable at narrow width and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester);
    await tester.scrollUntilVisible(
      find.text(S.current.fines_demo_signal),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
