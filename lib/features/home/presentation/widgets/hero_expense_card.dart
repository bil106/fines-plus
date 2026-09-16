// ignore_for_file: implementation_imports

import 'package:core_localization/generated/l10n.dart';
import 'package:core_localization/src/stats_localization.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/core/helpers/statistics_costs_presenter.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/localization/flutter_stats_localization.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  const HeroExpenseCard({super.key, required this.hasCar, required this.state, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currencyService = context.read<CurrencyService>();
    final settingsCubit = context.watch<SettingsCubit>();
    final currency = settingsCubit.state.currency;
    final unitStream = UnitStream(settingsCubit);
    final accent = ThemeConfig.hexToColor(context.watch<AppConfig>().primaryColorHex);

    final presenter = StatisticsCostsPresenter(
      state: state,
      loc: FlutterStatsLocalization(S.of(context)),
      currency: currency,
      currencyService: currencyService,
    );

    final current = state.expenseStats.total;
    final previous = state.previousExpenseStats.total;
    final deltaPercent = previous > 0 ? ((current - previous) / previous * 100) : null;

    final costPerKmConverted = currencyService.convert(stats.costPerKm, currency, fromCurrency: S.of(context).grn);
    final mileageUnit = settingsCubit.state.unit == 'mil' ? 'mil' : S.of(context).km;
    final fuelValue = unitStream.convertFuel(stats.averageFuelConsumption);
    final fuelUnit = settingsCubit.state.fuelConsumptionUnit == 'l/100km' ? "l/100${S.of(context).km}" : "mpg";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: AppBorders.radius16,
        // 155deg-ish diagonal + a stronger accent mix, matching the
        // Fines+OS hero-tile token (26% brand-primary into the card
        // surface) more closely than the original 18% wash.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.26), AppColors.neutreBlanc],
        ),
        border: Border.all(color: AppColors.dashboardCardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            presenter.currentMonthLabel,
            style: textTheme.bodySmall?.copyWith(color: AppColors.grey700),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                hasCar ? presenter.currentFormatted : "0",
                // JetBrains Mono, tabular figures - matches the mockup's
                // .hero-amount token (amounts don't jiggle width digit to
                // digit like a proportional font would).
                style: GoogleFonts.jetBrainsMono(
                  textStyle: textTheme.headlineMedium,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(currency, style: textTheme.titleMedium?.copyWith(color: AppColors.grey700)),
            ],
          ),
          if (hasCar && deltaPercent != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  deltaPercent <= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 14,
                  color: deltaPercent <= 0 ? AppColors.green : AppColors.redAccent,
                ),
                const SizedBox(width: 2),
                Text(
                  '${deltaPercent.abs().toStringAsFixed(0)}% ${presenter.previousMonthLabel}',
                  style: textTheme.bodySmall?.copyWith(
                    color: deltaPercent <= 0 ? AppColors.green : AppColors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          if (hasCar && current > 0) ...[
            const SizedBox(height: 12),
            _CategoryBar(categoryTotals: state.expenseStats.categoryTotals, total: current),
            const SizedBox(height: 8),
            _CategoryLegend(
              categoryTotals: state.expenseStats.categoryTotals,
              currency: currency,
              currencyService: currencyService,
              baseCurrency: S.of(context).grn,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
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
    case ExpenseCategory.other:
      return S.of(context).other;
  }
}

class _CategoryBar extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  final double total;

  const _CategoryBar({required this.categoryTotals, required this.total});

  @override
  Widget build(BuildContext context) {
    final segments = ExpenseCategory.values
        .map((c) => MapEntry(c, categoryTotals[c] ?? 0))
        .where((e) => e.value > 0)
        .toList();

    if (segments.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: AppBorders.radiusSmall,
      child: SizedBox(
        height: 8,
        child: Row(
          children: segments
              .map(
                (e) => Expanded(
                  flex: (e.value / total * 1000).round().clamp(1, 1000).toInt(),
                  child: Container(color: _categoryColor(e.key)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  final String currency;
  final CurrencyService currencyService;
  final String baseCurrency;

  const _CategoryLegend({
    required this.categoryTotals,
    required this.currency,
    required this.currencyService,
    required this.baseCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final entries = ExpenseCategory.values
        .map((c) => MapEntry(c, categoryTotals[c] ?? 0))
        .where((e) => e.value > 0)
        .toList();

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: entries.map((e) {
        final converted = currencyService.convert(e.value, currency, fromCurrency: baseCurrency);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: _categoryColor(e.key), shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              '${_categoryLabel(e.key, context)} ${converted.toStringAsFixed(0)} $currency',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey700),
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

  const _MiniStat({required this.icon, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grey700),
        const SizedBox(width: 6),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(width: 4),
        Text(unit, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey700)),
      ],
    );
  }
}
