
// ignore_for_file: implementation_imports

import 'package:core_localization/src/stats_localization.dart';

import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';

class StatisticsCostsPresenter {
  final StatisticsState state;
  final StatsLocalization loc;
  final String currency;
  final CurrencyService currencyService;

  StatisticsCostsPresenter({
    required this.state,
    required this.loc,
    required this.currency,
    required this.currencyService,
  });



  String get currentFormatted => _format(state.expenseStats.total);

  String get previousFormatted => _format(state.previousExpenseStats.total);

  bool get increased => state.expenseStats.total > state.previousExpenseStats.total;

  String get currentMonthLabel => _monthLabel(DateTime.now());

  String get previousMonthLabel {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    return _monthLabel(prev);
  }

  String _format(double valueUAH) {
    final converted = currencyService.convert(valueUAH, currency, fromCurrency: 'UAH');
    return converted.toStringAsFixed(0);
  }

  String _monthLabel(DateTime date) {
    final names = [
      loc.monthJan,
      loc.monthFeb,
      loc.monthMar,
      loc.monthApr,
      loc.monthMay,
      loc.monthJun,
      loc.monthJul,
      loc.monthAug,
      loc.monthSep,
      loc.monthOct,
      loc.monthNov,
      loc.monthDec,
    ];

    return "${names[date.month - 1]} ${date.year}";
  }
}
