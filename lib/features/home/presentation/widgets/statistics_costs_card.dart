import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/helpers/statistics_costs_presenter.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsCostsCard extends StatelessWidget {
  const StatisticsCostsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final presenter = StatisticsCostsPresenter(state);

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).costs_stat, style: textTheme.titleMedium),
              Container(height: 1, width: double.infinity, color: Colors.grey[300]),
              const SizedBox(height: 8),
              _buildRow(presenter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(StatisticsCostsPresenter presenter) {
    final arrowColor = presenter.increased ? Colors.redAccent : Colors.green;
    final arrowIcon = presenter.increased ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      children: [
        Image.asset('assets/icons/coin_stack.png', width: 36, height: 36, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(presenter.currentMonthLabel, style: const TextStyle(color: Colors.black54)),
            Text(
              "${presenter.currentTotal.toStringAsFixed(0)} UAH",
              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Icon(arrowIcon, color: arrowColor, size: 20),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  presenter.previousMonthLabel,
                  style: TextStyle(color: arrowColor, fontWeight: FontWeight.w500, fontSize: 16),
                ),
                Text(
                  presenter.previousTotal.toStringAsFixed(0),
                  style: TextStyle(color: arrowColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), child: child),
    );
  }
}
