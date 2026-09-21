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
    HistoryState? state,
  }) async {
    final cubit = HistoryStub(state ?? HistoryEmpty());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      BlocProvider<HistoryCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData(
            // The default InkSparkle splash loads a shader asset that can't be
            // decoded in the test environment.
            splashFactory: NoSplash.splashFactory,
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
          home: const FinesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('real empty history shows no fabricated fines', (tester) async {
    await open(tester);
    expect(find.text(S.current.no_fines), findsOneWidget);
    expect(find.text(S.current.pay), findsNothing);
  });

  testWidgets('real history preserves existing payment callback', (
    tester,
  ) async {
    final cubit = await open(
      tester,
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
}
