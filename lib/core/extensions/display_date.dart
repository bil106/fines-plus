import 'package:core_utils/formatters/plate_market.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Numeric date pattern the brand's market reads: US month-first
/// (11/15/2026), Latin America day-first with slashes (15/11/2026),
/// everywhere else the existing 15.11.2026. Display only - stored and
/// parsed dates keep `dd.MM.yyyy`.
String datePatternFor(PlateMarket market) => switch (market) {
  PlateMarket.us => 'MM/dd/yyyy',
  PlateMarket.mx || PlateMarket.ar => 'dd/MM/yyyy',
  _ => 'dd.MM.yyyy',
};

/// [date] formatted with [datePatternFor] the brand's market, optionally
/// followed by the time.
String displayDate(BuildContext context, DateTime date, {bool withTime = false}) {
  final pattern = datePatternFor(context.read<AppConfig>().plateMarket);
  return DateFormat(withTime ? '$pattern HH:mm' : pattern).format(date);
}
