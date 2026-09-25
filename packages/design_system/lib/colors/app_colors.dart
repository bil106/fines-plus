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

  // "No fines" success card (dashboard fines alert) border - pairs with
  // AppBrandTheme.statusSuccess/statusSuccessBg, which have no border
  // counterpart of their own.
  static const successCardBorder = Color(0xFFBFE3CC);

  static const oldAlerte = Color(0xffFFBF00);
  static const orange = Color(0xFFFF9800);

  static const neutreGreyDark = Color(0xff737373);
  static const neutreGrey = Color(0xffB9B9B9);
  static const neutreGreyLight = Color(0xffE2E2E2);
  static const neutreGrey100 = Color(0xffF5F5F5);
  static const grey50 = Color(0xFFFAFAFA);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const red700 = Color(0xFFD32F2F);

  static const black = Color(0xFF000000);
  static const black12 = Color(0x1F000000);
  static const black87 = Color(0xDD000000);
  static const black54 = Color(0x8A000000);
  static const black26 = Color(0x42000000);
  static const neutreBlanc = Color(0xffFFFFFF);
  static const transparent = Color(0x00000000);

  // Fixed neutral content colors from the dashboard redesign. Brand accents
  // and semantic status colors come from ColorScheme/AppBrandTheme.
  static const ink = Color(0xFF14161A);
  static const inkSoft = Color(0xFF202124);
  static const textSecondary = Color(0xFF616161);
  static const textMuted = Color(0xFF626262);
  static const textSubtle = Color(0xFF9BA1B0);

  // Identity-provider color, intentionally independent of app flavor.
  static const facebookBlue = Color(0xFF3E5D9F);

  // Expense-category colors: fixed per category, independent of the
  // active white-label brand (only the accent/primary color varies by
  // brand - see ThemeConfig.hexToColor(config.primaryColorHex)).
  static const catFuel = Color(0xFFFF9F1C);
  static const catService = Color(0xFF00A896);
  static const catTuning = Color(0xFF9B59B6);
  static const catCarWash = Color(0xFF22A6D9);
  static const catInsurance = Color(0xFF5B6CFF);
  static const catOther = Color(0xFF9AA1AD);
  static const catElectric = Color(0xFFEC407A);

  // Reminders list icon-square accents, one per ReminderKind, kept as their
  // own tokens (rather than reusing the expense-category colors) since they
  // color a different concept.
  static const reminderOilAccent = Color(0xFF00A896);
  static const reminderInsuranceAccent = Color(0xFF5B6CFF);
  static const reminderManualAccent = Color(0xFF22A6D9);

  // "Add expense" sheet tiles for the service sub-categories (Oil/Battery/
  // Tires): they share the catService expense category, so they get their
  // own accents to tell the tiles apart at a glance.
  static const quickOilAccent = Color(0xFFE0A800);
  static const quickBatteryAccent = Color(0xFF43A047);
  static const quickTiresAccent = Color(0xFF795548);

  // Dashed "add another row" button border (work lists in ТО/Тюнінг),
  // deliberately a warmer tone than surfaceBorder so the dashed affordance
  // reads as distinct from a regular field's solid border.
  static const dashedBorder = Color(0xFFC9C2A8);

  // Unselected radio/dot (subscription plan picker, onboarding page dots).
  static const inactiveDot = Color(0xFFD8D3C4);

  // Onboarding illustrations: fixed like the illustration assets they sit
  // on, so they don't follow the brand accent. Traffic-light lamp glows and
  // the tint dimming the lamps that are "off".
  static const trafficLightRed = Color(0xFFFF4D4F);
  static const trafficLightYellow = Color(0xFFFFC53D);
  static const trafficLightGreen = Color(0xFF3DDC84);
  static const trafficLightOff = Color(0xFF3A3E48);

  // Onboarding analytics chart: isometric bar faces (top to bottom
  // gradients) and the trend line (start to end).
  static const isoBarTop = Color(0xFFA9C1FF);
  static const isoBarFrontHigh = Color(0xFF4F6BF5);
  static const isoBarFrontMid = Color(0xFF8E86F0);
  static const isoBarFrontLow = Color(0xFFF7B9A4);
  static const isoBarSideHigh = Color(0xFF3148C9);
  static const isoBarSideMid = Color(0xFF6D63CF);
  static const isoBarSideLow = Color(0xFFD99A8C);
  static const trendLineStart = Color(0xFFF7A35C);
  static const trendLineEnd = Color(0xFF6FE0F2);

  // Dark bases the dashboard hero card's brand accent is mixed into (see
  // ThemeConfig.createTheme -> AppBrandTheme.heroBg*): darkest in the
  // bottom-left corner, lightening towards the top-right.
  static const heroBaseDeep = Color(0xFF0A1120);
  static const heroBase = Color(0xFF0E1726);
  static const heroBaseSoft = Color(0xFF1A2740);

  // Warm base the brand's surfaceBorder is mixed into for the dashboard
  // expense chart line (see ThemeConfig.createTheme -> AppBrandTheme.chartLine),
  // so the chart stays in the app's beige tones for every flavor.
  static const chartWarmBase = Color(0xFF8A6A3A);

  // Month-over-month delta on the dark hero card - lighter than
  // statusSuccess/statusDanger so they keep contrast on a dark surface.
  static const successOnDark = Color(0xFF6EE7A0);
  static const dangerOnDark = Color(0xFFFF8A80);

  // Ukrainian licence plate, drawn on the hero card. Fixed by the real
  // plate's look, independent of the white-label brand.
  static const plateFrameLight = Color(0xFFF7F8FA);
  static const plateFrameMid = Color(0xFFC3C9D2);
  static const plateFrameDark = Color(0xFF9AA2AE);
  static const plateInk = Color(0xFF111318);
  static const plateSurfaceShade = Color(0xFFF1F3F6);
  static const plateStripTop = Color(0xFF2F62E6);
  static const plateStripBottom = Color(0xFF1741B5);
  static const plateFlagBlue = Color(0xFF0057B7);
  static const plateFlagYellow = Color(0xFFFFD700);

  // Note: the dashboard's warm-neutral background/border/divider and the
  // unpaid-fines alert colors used to live here as fixed consts. They are
  // now per-brand theme tokens (AppConfig -> ThemeConfig.createTheme ->
  // AppBrandTheme, see packages/design_system/lib/theme/app_brand_theme.dart)
  // so every white-label flavor can set its own values instead of all
  // brands sharing one hardcoded look. Read them via
  // `context.brandTheme.<token>`, not as AppColors constants.
}
