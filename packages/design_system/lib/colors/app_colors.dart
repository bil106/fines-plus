import 'package:flutter/material.dart' show Color, Colors;

abstract final class AppColors {
  static const darkBlue = Color(0xff092A5E);
  static const oldDarkBlue = Color(0xff092A5E);
  static const deepBlue = Color(0xff1B115C);
  static const energyBlue = Color(0xff3567F6);
  static const energyBlue25 = Color(0xffCCD9FD);
  static const energyBlue50 = Color(0xFFE3F2FD);
  static const blueSky = Color(0xff70CBF4);
  static const blueAccent = Color(0xff448AFF);
  static const blue700 = Color(0xFF1976D2);
  static final blueGrey08 = Colors.blueGrey.withOpacity(0.08);
  static final blueGrey25 = Colors.blueGrey.withOpacity(0.25);

  static const cl = Color(0xffE30613);
  static const red = Color(0xffD40E14);
  static const redAccent = Color(0xFFFF5252);
  static const amber = Color(0xFFFFC107);
  static const lightRed = Color(0xFFF78A8A);
  static const purpleRed = Color(0xFF7D2AE8);
  static const darkRed = Color(0xFFBE040A);

  static const cm = Color(0xff00A5B6);
  static const colcm = Color(0xFF00C6FF);
  static const green = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFF8BC34A);
  static const greenAccent = Color(0xFF69F0AE);

  static const oldAlerte = Color(0xffFFBF00);
  static const orange = Color(0xFFFF9800);

  static const neutreGreyDark = Color(0xff737373);
  static const neutreGrey = Color(0xffB9B9B9);
  static const neutreGreyLight = Color(0xffE2E2E2);
  static const neutreGrey100 = Color(0xffF5F5F5);
  static const grey50 = Color(0xFFFAFAFA);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey700 = Color(0xFF616161);

  static const black = Color(0xFF000000);
  static const black87 = Color(0xDD000000);
  static const black26 = Color(0x42000000);
  static const neutreBlanc = Color(0xffFFFFFF);
  static const transparent = Color(0x00000000);

  // Expense-category colors: fixed per category, independent of the
  // active white-label brand (only the accent/primary color varies by
  // brand - see ThemeConfig.hexToColor(config.primaryColorHex)).
  static const catFuel = Color(0xFFFF9F1C);
  static const catService = Color(0xFF00A896);
  static const catTuning = Color(0xFF5B6CFF);
  static const catCarWash = Color(0xFF22A6D9);
  static const catOther = Color(0xFF9AA1AD);

  // Unpaid-fines alert card (matches the Fines+OS mockup's alert token set).
  static const alertBg = Color(0xFFFBE1E1);
  static const alertBorder = Color(0xFFF3B9B9);
  static const alertFg = Color(0xFFB23A3E);
}
