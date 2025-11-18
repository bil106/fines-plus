// ignore_for_file: implementation_imports

import 'package:core_localization/generated/l10n.dart';
import 'package:core_localization/src/stats_localization.dart';

class FlutterStatsLocalization implements StatsLocalization {
  final S s;
  FlutterStatsLocalization(this.s);

  @override
  String get monthJan => s.month_jan;
  @override
  String get monthFeb => s.month_feb;
  @override
  String get monthMar => s.month_mar;
  @override
  String get monthApr => s.month_apr;
  @override
  String get monthMay => s.month_may;
  @override
  String get monthJun => s.month_jun;
  @override
  String get monthJul => s.month_jul;
  @override
  String get monthAug => s.month_aug;
  @override
  String get monthSep => s.month_sep;
  @override
  String get monthOct => s.month_oct;
  @override
  String get monthNov => s.month_nov;
  @override
  String get monthDec => s.month_dec;
  @override
  String get costsStatTitle => s.costs_stat;
}
