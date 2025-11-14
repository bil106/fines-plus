import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter/material.dart';

class StatisticsCostsPresenter {
  final StatisticsState state;
  final BuildContext context;

  StatisticsCostsPresenter(this.state, this.context);

  double get currentTotal => state.expenseStats.total;
  double get previousTotal => state.previousExpenseStats.total;
  bool get increased => currentTotal > previousTotal;

  String get currentMonthLabel {
    final now = DateTime.now();
    return _getMonthLabel(now);
  }

  String get previousMonthLabel {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    return _getMonthLabel(prevMonth);
  }

  String _getMonthLabel(DateTime date) {
    final s = S.of(context);

    final monthNames = [
      s.month_jan,
      s.month_feb,
      s.month_mar,
      s.month_apr,
      s.month_may,
      s.month_jun,
      s.month_jul,
      s.month_aug,
      s.month_sep,
      s.month_oct,
      s.month_nov,
      s.month_dec,
    ];

    return "${monthNames[date.month - 1]} ${date.year}";
  }
}
