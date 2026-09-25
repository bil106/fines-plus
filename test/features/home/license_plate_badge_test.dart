import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/features/home/presentation/widgets/license_plate_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> _pumpBadge(WidgetTester tester, String market, String number) {
  return tester.pumpWidget(
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
        theme: ThemeData(
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
        home: Scaffold(body: Center(child: LicensePlateBadge(number: number))),
      ),
    ),
  );
}

void main() {
  testWidgets('UA plate: UA strip and "AA 1234 BB" spacing', (tester) async {
    await _pumpBadge(tester, 'UA', 'KA7777AB');
    expect(find.text('UA'), findsOneWidget);
    expect(find.text('KA 7777 AB'), findsOneWidget);
    expect(find.text('USA'), findsNothing);
  });

  testWidgets('ES plate: EU "E" strip and "1234 BCD" spacing', (tester) async {
    await _pumpBadge(tester, 'ES', '1234BCD');
    expect(find.text('E'), findsOneWidget);
    expect(find.text('1234 BCD'), findsOneWidget);
    expect(find.text('UA'), findsNothing);
  });

  testWidgets('US plate: USA header, number as typed', (tester) async {
    await _pumpBadge(tester, 'US', '8abc123');
    expect(find.text('USA'), findsOneWidget);
    expect(find.text('8ABC123'), findsOneWidget);
    expect(find.text('UA'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
