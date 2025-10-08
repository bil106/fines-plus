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
  final VoidCallback? onMaintenance;

  const ExpenseStatsCard({super.key, required this.stats, this.onMaintenance});

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

            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0.5,
                  centerSpaceRadius: 40,
                  sections: stats.categoryTotals.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      radius: 50,

                      gradient: _gradientForCategory(e.key),

                      title: e.value.toStringAsFixed(0),
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      borderSide: const BorderSide(color: AppColors.neutreBlanc, width: 1),
                    );
                  }).toList(),
                ),
              ),
            ),
           AppSpacers.verticalMedium,

          GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, 
              childAspectRatio: 4, 
              mainAxisSpacing: 6,
              crossAxisSpacing: 8,
              children: ExpenseCategory.values.map((cat) {
                return _LegendItem(gradient: _gradientForCategory(cat), text: _categoryName(cat));
              }).toList(),
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              TextButton(
                  onPressed: () {
                    if (onMaintenance != null) onMaintenance!();
                  },
                  child: Text(S.current.open_statistics),
                ),


              ],
            ),
          ],
        ),
      ),
    );
  }

  Gradient _gradientForCategory(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.fuel:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenAccent, AppColors.green],
        );
      case ExpenseCategory.service:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightRed, AppColors.darkRed],
        );
      case ExpenseCategory.tuning:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.energyBlue25, AppColors.darkBlue],
        );
          case ExpenseCategory.carWash:
        
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.energyBlue25, AppColors.greenAccent],
        );
      case ExpenseCategory.other:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.grey50,AppColors.grey700],
        );
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
         case ExpenseCategory.carWash:
      
        return S.current.car_wash;
      case ExpenseCategory.other:
        return S.current.other;
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Gradient gradient;
  final String text;

  const _LegendItem({required this.gradient, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
