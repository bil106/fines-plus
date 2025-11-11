// ignore_for_file: file_names

import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';

class StatisticsMileagePresenter {
  final StatisticsState state;

  StatisticsMileagePresenter(this.state);

  int get mileageThisMonth => state.currentMonthMileage.toInt();
  int get previousMileage => state.previousMonthMileage.toInt();

  int get changePercent =>
      previousMileage > 0 ? ((mileageThisMonth - previousMileage) / previousMileage * 100).toInt() : 0;

  bool get isIncreased => changePercent >= 0;

  String get monthLabel => _monthName(DateTime.now().month);

  Icon get arrowIcon => Icon(
    isIncreased ? Icons.arrow_upward : Icons.arrow_downward,
    color: isIncreased ? Colors.red : Colors.green,
    size: 20,
  );

  Color get changeColor => isIncreased ? Colors.red : Colors.green;

  String get mileageThisMonthFormatted =>
      "${NumberFormat.decimalPattern('uk').format(mileageThisMonth)}${S.current.km}";

  static String _monthName(int month) {
    const months = ["Січ", "Лют", "Бер", "Квіт", "Трав", "Черв", "Лип", "Серп", "Верес", "Жовт", "Лист", "Груд"];
    return months[month - 1];
  }
}
