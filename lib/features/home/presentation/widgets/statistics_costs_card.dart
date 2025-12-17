import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/core/helpers/statistics_costs_presenter.dart';
import 'package:fines_plus/features/home/presentation/localization/flutter_stats_localization.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsCostsCard extends StatelessWidget {
  const StatisticsCostsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hasCar = context.watch<CarCubit>().state.carNumber.isNotEmpty;

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        if (!hasCar) {
          final zeroAmount = "0";
          final currency = context.watch<SettingsCubit>().state.currency;

          final presenter = StatisticsCostsPresenter(
            state: state,
            loc: FlutterStatsLocalization(S.of(context)),
            currency: currency,
            currencyService: context.read<CurrencyService>(),
          );
          return _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).costs_stat, style: Theme.of(context).textTheme.titleMedium),
                const Divider(height: 16, thickness: 1),
                Row(
                  children: [
                    Image.asset('assets/icons/coin_stack.png', width: 36, height: 36, color: Colors.grey),
                    const SizedBox(width: 12),
                    _buildAmount(
                      label: presenter.currentMonthLabel,
                      amount: zeroAmount,
                      currency: currency,
                      color: Colors.blueAccent,
                      fontSize: 22,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.grey, size: 20),
                        const SizedBox(width: 4),
                        _buildAmount(
                          label: presenter.previousMonthLabel,
                          amount: zeroAmount,
                          currency: currency,
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final currency = context.watch<SettingsCubit>().state.currency;
        final presenter = StatisticsCostsPresenter(
          state: state,
          loc: FlutterStatsLocalization(S.of(context)),
          currency: currency,
          currencyService: context.read<CurrencyService>(),
        );

        final arrowColor = presenter.increased ? Colors.redAccent : Colors.green;
        final arrowIcon = presenter.increased ? Icons.arrow_upward : Icons.arrow_downward;

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(presenter.loc.costsStatTitle, style: Theme.of(context).textTheme.titleMedium),
              const Divider(height: 16, thickness: 1),
              Row(
                children: [
                  Image.asset('assets/icons/coin_stack.png', width: 36, height: 36, color: Colors.grey),
                  const SizedBox(width: 12),
                  _buildAmount(
                    label: presenter.currentMonthLabel,
                    amount: presenter.currentFormatted,
                    currency: currency,
                    color: Colors.blueAccent,
                    fontSize: 22,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(arrowIcon, color: arrowColor, size: 20),
                      const SizedBox(width: 4),
                      _buildAmount(
                        label: presenter.previousMonthLabel,
                        amount: presenter.previousFormatted,
                        currency: currency,
                        color: arrowColor,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmount({
    required String label,
    required String amount,
    required String currency,
    required Color color,
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          "$amount $currency",
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), child: child),
    );
  }
}
