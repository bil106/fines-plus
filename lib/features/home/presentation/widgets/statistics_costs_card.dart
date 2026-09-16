import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
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
    final hasCar = context.watch<CarCubit>().state.carId.isNotEmpty;
    final currency = context.watch<SettingsCubit>().state.currency;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final presenter = StatisticsCostsPresenter(
          state: state,
          loc: FlutterStatsLocalization(S.of(context)),
          currency: currency,
          currencyService: context.read<CurrencyService>(),
        );

        final arrowColor = presenter.increased ? AppColors.redAccent : AppColors.green;
        final arrowIcon = presenter.increased ? Icons.arrow_upward : Icons.arrow_downward;

        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(presenter.loc.costsStatTitle, style: textTheme.titleMedium),
              const Divider(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/icons/coin_stack.png', width: 36, height: 36, color: Colors.grey),
                  const SizedBox(width: 12),

                  Expanded(
                    child: _AmountBlock(
                      label: presenter.currentMonthLabel,
                      amount: hasCar ? presenter.currentFormatted : "0",
                      currency: currency,
                      color: AppColors.blueAccent,
                      valueStyle: textTheme.titleLarge,
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(arrowIcon, color: arrowColor, size: 20),
                      const SizedBox(width: 6),
                      _AmountBlock(
                        label: presenter.previousMonthLabel,
                        amount: hasCar ? presenter.previousFormatted : "0",
                        currency: currency,
                        color: arrowColor,
                        valueStyle: textTheme.titleMedium,
                        alignEnd: true,
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

  Widget _buildCard({required Widget child}) {
    // Flat, bordered card matching the Fines+OS mockup's .car-card/.tier
    // token (1px border, no drop shadow) - was a Material Card with
    // theme-default elevation before this pass.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutreBlanc,
        border: Border.all(color: AppColors.dashboardCardBorder),
        borderRadius: AppBorders.radius16,
      ),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14), child: child),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;
  final TextStyle? valueStyle;
  final bool alignEnd;

  const _AmountBlock({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    this.valueStyle,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "$amount $currency",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: valueStyle?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
