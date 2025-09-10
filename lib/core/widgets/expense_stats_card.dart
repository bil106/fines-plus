import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/widgets/extensions/monthly_expense_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseStatsCard extends StatelessWidget {
  final MonthlyExpenseStats stats;

  const ExpenseStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.current.cost_statistics, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 28, color: Colors.grey),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats.monthLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "${stats.total.toStringAsFixed(0)} ${S.current.grn}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pie chart
            SizedBox(
              height: 200,
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
            const SizedBox(height: 12),

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
        return Colors.greenAccent;
      case ExpenseCategory.service:
        return Colors.redAccent;
      case ExpenseCategory.tuning:
        return Colors.blueAccent;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  String _categoryName(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.fuel:
        return S.current.fuel;
      case ExpenseCategory.service:
        return S.current.repair;
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
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
