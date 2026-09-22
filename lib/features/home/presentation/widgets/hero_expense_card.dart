// ignore_for_file: implementation_imports

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/core/helpers/statistics_costs_presenter.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:fines_plus/core/extensions/monthly_expense_stats.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/localization/flutter_stats_localization.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/theme/app_brand_theme.dart';

/// The dashboard's headline expense summary: amount for the current month,
/// the delta vs. last month, and a per-category breakdown bar - replaces
/// MainStatsCard's circular-gauge look with the Fines+OS design direction.
///
/// The cost-per-km/fuel-consumption figures MainStatsCard used to show as
/// rings are kept (same data, same unit/currency conversion), just as a
/// compact line instead of a painted gauge - no functionality dropped.
class HeroExpenseCard extends StatelessWidget {
  final bool hasCar;
  final StatisticsState state;
  final MainStats stats;

  const HeroExpenseCard({
    super.key,
    required this.hasCar,
    required this.state,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currencyService = context.read<CurrencyService>();
    final settingsCubit = context.watch<SettingsCubit>();
    final currency = settingsCubit.state.currency;
    final unitStream = UnitStream(settingsCubit);
    final accent = ThemeConfig.hexToColor(
      context.watch<AppConfig>().primaryColorHex,
    );

    final presenter = StatisticsCostsPresenter(
      state: state,
      loc: FlutterStatsLocalization(S.of(context)),
      currency: currency,
      currencyService: currencyService,
    );

    final current = state.expenseStats.total;
    final segments = _segments(context, state.expenseStats);
    final previous = state.previousExpenseStats.total;
    final deltaPercent = previous > 0
        ? ((current - previous) / previous * 100)
        : null;

    final costPerKmConverted = currencyService.convert(
      stats.costPerKm,
      currency,
      fromCurrency: S.of(context).grn,
    );
    final mileageUnit = settingsCubit.state.unit == 'mil'
        ? 'mil'
        : S.of(context).km;
    final fuelValue = unitStream.convertFuel(stats.averageFuelConsumption);
    final fuelUnit = settingsCubit.state.fuelConsumptionUnit == 'l/100km'
        ? "l/100${S.of(context).km}"
        : "mpg";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: AppBorders.radius16,
        // 135deg diagonal, brand-primary mixed 26% into white and reaching
        // solid white by the 65% mark - matches the Fines+OS hero-tile
        // token exactly (color-mix(accent 26%, #FFFFFF), #FFFFFF 65%).
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.26), AppColors.neutreBlanc],
          stops: const [0.0, 0.65],
        ),
        // Border-only, no drop shadow - the mockup's .hero-tile/.car-card/
        // .tier cards are all flat (1px border), so this now matches them
        // and the other dashboard cards instead of standing out as the one
        // elevated one.
        border: Border.all(color: context.brandTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            presenter.currentMonthLabel,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.grey700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                hasCar ? presenter.currentFormatted : "0",
                // Brand money font (tabular mono figures by default),
                // per-flavor via AppConfig.monoFontFamily.
                style: textTheme.headlineMedium
                    ?.merge(context.brandTheme.moneyTextStyle)
                    .copyWith(fontSize: 34),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.grey700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (hasCar && deltaPercent != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  deltaPercent <= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 14,
                  color: deltaPercent <= 0
                      ? context.brandTheme.statusSuccess
                      : context.brandTheme.statusDanger,
                ),
                const SizedBox(width: 2),
                Text(
                  '${deltaPercent.abs().toStringAsFixed(0)}% ${presenter.previousMonthLabel}',
                  style: textTheme.bodySmall?.copyWith(
                    color: deltaPercent <= 0
                        ? context.brandTheme.statusSuccess
                        : context.brandTheme.statusDanger,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],

          if (hasCar && current > 0) ...[
            const SizedBox(height: 6),
            _CategoryBar(segments: segments, total: current),
            const SizedBox(height: 8),
            _CategoryLegend(
              segments: segments,
              currency: currency,
              currencyService: currencyService,
              baseCurrency: S.of(context).grn,
            ),
          ],

          const SizedBox(height: 6),
          Divider(height: 1, color: context.brandTheme.surfaceBorder),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.speed,
                  value: costPerKmConverted.toStringAsFixed(1),
                  unit: '$currency/$mileageUnit',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_gas_station,
                  value: fuelValue.toStringAsFixed(1),
                  unit: fuelUnit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _categoryColor(ExpenseCategory c) {
  switch (c) {
    case ExpenseCategory.fuel:
      return AppColors.catFuel;
    case ExpenseCategory.service:
      return AppColors.catService;
    case ExpenseCategory.tuning:
      return AppColors.catTuning;
    case ExpenseCategory.carWash:
      return AppColors.catCarWash;
    case ExpenseCategory.insurance:
      return AppColors.catInsurance;
    case ExpenseCategory.other:
      return AppColors.catOther;
  }
}

String _categoryLabel(ExpenseCategory c, BuildContext context) {
  switch (c) {
    case ExpenseCategory.fuel:
      return S.of(context).fuel;
    case ExpenseCategory.service:
      return S.of(context).service;
    case ExpenseCategory.tuning:
      return S.of(context).tuning;
    case ExpenseCategory.carWash:
      return S.of(context).car_wash;
    case ExpenseCategory.insurance:
      return S.of(context).insurance;
    case ExpenseCategory.other:
      return S.of(context).other;
  }
}

/// One slice of the month's breakdown: a category, except that the electric
/// part of the fuel total is split out so a hybrid's petrol and electricity
/// show apart.
class _Segment {
  final Color color;
  final String label;
  final double amount;

  const _Segment({
    required this.color,
    required this.label,
    required this.amount,
  });
}

List<_Segment> _segments(BuildContext context, MonthlyExpenseStats stats) {
  final result = <_Segment>[];
  for (final category in ExpenseCategory.values) {
    var amount = stats.categoryTotals[category] ?? 0;
    if (category == ExpenseCategory.fuel) {
      final electric = stats.electricTotal.clamp(0.0, amount);
      amount -= electric;
      if (amount > 0) {
        result.add(
          _Segment(
            color: _categoryColor(category),
            label: _categoryLabel(category, context),
            amount: amount,
          ),
        );
      }
      if (electric > 0) {
        result.add(
          _Segment(
            color: AppColors.catElectric,
            label: S.of(context).fuel_electric,
            amount: electric,
          ),
        );
      }
    } else if (amount > 0) {
      result.add(
        _Segment(
          color: _categoryColor(category),
          label: _categoryLabel(category, context),
          amount: amount,
        ),
      );
    }
  }
  return result;
}

class _CategoryBar extends StatelessWidget {
  final List<_Segment> segments;
  final double total;

  const _CategoryBar({required this.segments, required this.total});

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: AppBorders.radiusSmall,
      child: SizedBox(
        height: 8,
        child: Row(
          children: segments
              .map(
                (e) => Expanded(
                  flex: (e.amount / total * 1000)
                      .round()
                      .clamp(1, 1000)
                      .toInt(),
                  child: Container(color: e.color),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final List<_Segment> segments;
  final String currency;
  final CurrencyService currencyService;
  final String baseCurrency;

  const _CategoryLegend({
    required this.segments,
    required this.currency,
    required this.currencyService,
    required this.baseCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: segments.map((e) {
        final converted = currencyService.convert(
          e.amount,
          currency,
          fromCurrency: baseCurrency,
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              '${e.label} ${converted.toStringAsFixed(0)} $currency',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey700,
                fontSize: 11,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey700),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }
}
