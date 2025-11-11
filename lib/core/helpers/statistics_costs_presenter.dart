import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';

class StatisticsCostsPresenter {
  final StatisticsState state;

  StatisticsCostsPresenter(this.state);

  double get currentTotal => state.expenseStats.total;
  double get previousTotal => state.previousExpenseStats.total;

  bool get increased => currentTotal > previousTotal;

  String get currentMonthLabel =>
      state.expenseStats.monthLabel.isNotEmpty ? state.expenseStats.monthLabel : _getMonthLabel(DateTime.now());

  String get previousMonthLabel {
    if (state.previousExpenseStats.monthLabel.isNotEmpty) {
      return state.previousExpenseStats.monthLabel;
    }
    return _getPreviousMonthLabel(currentMonthLabel);
  }

  String _getMonthLabel(DateTime date) {
    const monthNames = ["Січ", "Лют", "Бер", "Квіт", "Трав", "Черв", "Лип", "Серп", "Верес", "Жовт", "Лист", "Груд"];
    return "${monthNames[date.month - 1]} '${date.year % 100}";
  }

  String _getPreviousMonthLabel(String currentMonthLabel) {
    final parts = currentMonthLabel.split(' ');
    if (parts.length != 2) return currentMonthLabel;

    const monthNames = ["Січ", "Лют", "Бер", "Квіт", "Трав", "Черв", "Лип", "Серп", "Верес", "Жовт", "Лист", "Груд"];
    final currentMonthIndex = monthNames.indexOf(parts[0]);
    int prevMonthIndex = currentMonthIndex - 1;
    int year = int.tryParse(parts[1].replaceAll("'", "")) ?? DateTime.now().year;

    if (prevMonthIndex < 0) {
      prevMonthIndex = 11;
      year -= 1;
    }

    return "${monthNames[prevMonthIndex]} '$year";
  }
}
