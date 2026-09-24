import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:fines_plus/core/extensions/currency_service.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'dashboard_card.dart';

/// Dashboard "Витрати" card: a line chart of monthly expense totals for
/// the last 6 or 12 months.
/// Tapping a point shows that month's total in the tooltip.
class ExpenseTrendCard extends StatefulWidget {
  const ExpenseTrendCard({super.key});

  @override
  State<ExpenseTrendCard> createState() => _ExpenseTrendCardState();
}

class _ExpenseTrendCardState extends State<ExpenseTrendCard> {
  static const _periods = [6, 12];

  int _months = 6;

  /// Index of the point showing the tooltip; null means the latest month.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        final months = state.recentMonths.length > _months
            ? state.recentMonths.sublist(state.recentMonths.length - _months)
            : state.recentMonths;
        if (months.isEmpty) return const SizedBox.shrink();

        final currency = context.watch<SettingsCubit>().state.currency;
        final currencyService = context.read<CurrencyService>();
        final baseCurrency = S.of(context).grn;
        final totals = [
          for (final month in months)
            currencyService.convert(
              month.total,
              currency,
              fromCurrency: baseCurrency,
            ),
        ];
        final selected = (_selected ?? totals.length - 1).clamp(
          0,
          totals.length - 1,
        );

        return DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                months: _months,
                periods: _periods,
                onPeriodChanged: (value) => setState(() {
                  _months = value;
                  _selected = null;
                }),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 90,
                child: _TrendChart(
                  months: [for (final month in months) month.month],
                  totals: totals,
                  selected: selected,
                  currency: currency,
                  onSelect: (index) => setState(() => _selected = index),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final int months;
  final List<int> periods;
  final ValueChanged<int> onPeriodChanged;

  const _Header({
    required this.months,
    required this.periods,
    required this.onPeriodChanged,
  });

  String _label(BuildContext context, int value) => value == 12
      ? S.of(context).chart_period_12m
      : S.of(context).chart_period_6m;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        PopupMenuButton<int>(
          initialValue: months,
          onSelected: onPeriodChanged,
          itemBuilder: (context) => [
            for (final value in periods)
              PopupMenuItem(value: value, child: Text(_label(context, value))),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.brandTheme.surfaceBg,
              borderRadius: AppBorders.radius50,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _label(context, months),
                  style: textTheme.labelLarge?.copyWith(
                    color: context.brandTheme.chartLine,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: context.brandTheme.chartLine,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<DateTime> months;
  final List<double> totals;
  final int selected;
  final String currency;
  final ValueChanged<int> onSelect;

  const _TrendChart({
    required this.months,
    required this.totals,
    required this.selected,
    required this.currency,
    required this.onSelect,
  });

  String _monthLabel(BuildContext context, DateTime month) {
    final locale = Localizations.localeOf(context).toString();
    final label = DateFormat.MMM(locale).format(month).replaceAll('.', '');
    return label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brandTheme;
    final line = brand.chartLine;
    final textTheme = Theme.of(context).textTheme;
    final spots = [
      for (var i = 0; i < totals.length; i++) FlSpot(i.toDouble(), totals[i]),
    ];
    final maxTotal = totals.fold<double>(0, (a, b) => a > b ? a : b);
    // Headroom above the highest point for the tooltip pill.
    final maxY = maxTotal <= 0 ? 1.0 : maxTotal * 1.45;
    // With 12 months every other label, so they don't collide.
    final labelStep = totals.length > 6 ? 2 : 1;

    final bar = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      color: line,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: (spot, _, _, index) => FlDotCirclePainter(
          radius: index == selected ? 6 : 4,
          color: line,
          strokeWidth: index == selected ? 3 : 0,
          strokeColor: AppColors.neutreBlanc,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.28), line.withValues(alpha: 0)],
        ),
      ),
    );

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (totals.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [bar],
        showingTooltipIndicators: [
          ShowingTooltipIndicators([LineBarSpot(bar, 0, spots[selected])]),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            final spot = response?.lineBarSpots?.firstOrNull;
            if (event is FlTapUpEvent && spot != null) {
              onSelect(spot.spotIndex);
            }
          },
          getTouchedSpotIndicator: (_, indexes) => [
            for (final _ in indexes)
              const TouchedSpotIndicatorData(
                FlLine(color: Colors.transparent),
                FlDotData(show: false),
              ),
          ],
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => line,
            tooltipBorderRadius: AppBorders.radiusLarge,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            tooltipMargin: 10,
            fitInsideHorizontally: true,
            getTooltipItems: (touched) => [
              for (final spot in touched)
                LineTooltipItem(
                  '${spot.y.toStringAsFixed(0)} $currency',
                  (textTheme.labelLarge ?? const TextStyle()).copyWith(
                    color: AppColors.neutreBlanc,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        gridData: FlGridData(
          drawHorizontalLine: false,
          verticalInterval: 1,
          getDrawingVerticalLine: (_) =>
              FlLine(color: brand.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index != value ||
                    index < 0 ||
                    index >= months.length ||
                    (totals.length - 1 - index) % labelStep != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _monthLabel(context, months[index]),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
