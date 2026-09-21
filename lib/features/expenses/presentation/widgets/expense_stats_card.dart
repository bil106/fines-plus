import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/extensions/monthly_expense_stats.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        Text(
                          "${context.read<SettingsCubit>().convertFromUAH(stats.total).toStringAsFixed(0)} ${context.read<SettingsCubit>().getCurrencyLabel(context, context.read<SettingsCubit>().state.currency)}",
                          style: textTheme.black20bold,
                        ),
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
                    final convertedValue = context.read<SettingsCubit>().convertFromUAH(e.value);
                    return PieChartSectionData(
                      value: convertedValue,
                      radius: 50,
                      color: _colorForCategory(e.key),
                      title: convertedValue.toStringAsFixed(0),
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutreBlanc,
                      ),
                      borderSide: const BorderSide(color: AppColors.neutreBlanc, width: 1),
                    );
                  }).toList(),
                ),
              ),
            ),
            AppSpacers.verticalSmallMedium,

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 8,
              children: ExpenseCategory.values.map((cat) {
                return _LegendItem(color: _colorForCategory(cat), text: _categoryName(cat));
              }).toList(),
            ),

            if (onMaintenance != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: onMaintenance, child: Text(S.current.open_statistics)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Same tokens as the dashboard's HeroExpenseCard so both screens match.
  Color _colorForCategory(ExpenseCategory cat) {
    switch (cat) {
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
      case ExpenseCategory.insurance:
        return S.current.insurance;
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
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4), 
        Expanded(
          child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(text)),
        ),
      ],
    );
  }
}
