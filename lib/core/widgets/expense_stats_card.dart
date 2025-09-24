import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/extensions/monthly_expense_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseStatsCard extends StatelessWidget {
  final MonthlyExpenseStats stats;

  const ExpenseStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.current.cost_statistics, style: textTheme.black16bold),
            const Divider(color: AppColors.neutreGrey),
           
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 28, color: AppColors.energyBlue),
                    AppSpacers.horizontalSmallMedium,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats.monthLabel, style: textTheme.black14bold),
                        Text("${stats.total.toStringAsFixed(0)} ${S.current.grn}", style: textTheme.black20bold),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            AppSpacers.verticalMediumLarge,

            // Pie chart
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: stats.categoryTotals.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      color: _colorForCategory(e.key),
                      title: e.value.toStringAsFixed(0),
                      radius: 50,
                    );
                  }).toList(),
                ),
              ),
            ),
            AppSpacers.verticalMedium,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ExpenseCategory.values.map((cat) {
                return _LegendItem(color: _colorForCategory(cat), text: _categoryName(cat));
              }).toList(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [TextButton(onPressed: () {}, child: Text(S.current.open_statistics))],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForCategory(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.fuel:
        return AppColors.greenAccent;
      case ExpenseCategory.service:
        return AppColors.redAccent;
      case ExpenseCategory.tuning:
        return AppColors.blueAccent;
      case ExpenseCategory.other:
        return AppColors.neutreGrey;
    }
  }

  String _categoryName(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.fuel:
        return S.current.fuel;
      case ExpenseCategory.service:
        return S.current.service;
      case ExpenseCategory.tuning:
        return S.current.tuning;
      case ExpenseCategory.other:
        return S.current.other;
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        AppSpacers.horizontalXSmall,
        Text(text),
      ],
    );
  }
}
