import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsCostsCard extends StatelessWidget {
  const StatisticsCostsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final currentMonthTotal = state.expenseStats.total;
        final previousMonthTotal = state.previousExpenseStats.total;

        final bool increased = currentMonthTotal > previousMonthTotal;
        final arrowIcon = increased ? Icons.arrow_upward : Icons.arrow_downward;
        final arrowColor = increased ? Colors.redAccent : Colors.green;

        final currentMonthLabel = state.expenseStats.monthLabel.isNotEmpty
            ? state.expenseStats.monthLabel
            : _getCurrentMonthLabel();

        final previousMonthLabel = state.previousExpenseStats.monthLabel.isNotEmpty
            ? state.previousExpenseStats.monthLabel
            : _getPreviousMonthLabel(currentMonthLabel);

        return _buildCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentMonthLabel, style: const TextStyle(color: Colors.black54)),
                  Text(
                    "${currentMonthTotal.toStringAsFixed(0)} UAH",
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),

              
              Row(
                children: [
                  Icon(arrowIcon, color: arrowColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "$previousMonthLabel ${previousMonthTotal.toStringAsFixed(0)}",
                    style: TextStyle(color: arrowColor, fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  String _getCurrentMonthLabel() {
    final now = DateTime.now();
    const monthNames = ["Січ", "Лют", "Бер", "Квіт", "Трав", "Черв", "Лип", "Серп", "Верес", "Жовт", "Лист", "Груд"];
    return "${monthNames[now.month - 1]} '${now.year % 100}";
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
