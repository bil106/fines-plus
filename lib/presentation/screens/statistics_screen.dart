import 'package:core_cubit/cubit/statistics/statistics_cubit.dart';
import 'package:core_cubit/cubit/statistics/statistics_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:fines_plus/core/widgets/add_mileage_dialog.dart';
import 'package:fines_plus/core/widgets/expense_stats_card.dart';
import 'package:fines_plus/core/widgets/trend_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => StatisticsCubit()..loadAll(), child: const _StatisticsScreenView());
  }
}

class _StatisticsScreenView extends StatelessWidget {
  const _StatisticsScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();

        final currentMileage = state.mileageRecords.firstWhere(
          (r) => r.month.year == now.year && r.month.month == now.month,
          orElse: () => MileageRecord(month: now, startOdometer: 0, endOdometer: 0),
        );

        final yearRecords = state.mileageRecords.where((r) => r.month.year == now.year).toList();
        final averageYear = yearRecords.isNotEmpty
            ? yearRecords.map((r) => r.mileage).reduce((a, b) => a + b) ~/ yearRecords.length
            : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final record = await showDialog<MileageRecord>(
                    context: context,
                    builder: (_) => AddMileageDialog(initialRecord: currentMileage),
                  );

                  if (record != null) {
                    context.read<StatisticsCubit>().addMileage(record);
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).mileage_statistics,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.directions_car, size: 28, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          VehicleFormatters.formatMonthYear(currentMileage.month),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),

                                        Text(
                                          "${currentMileage.mileage} ${S.of(context).km}",
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Row(children: [const SizedBox(width: 8), TrendIcon(isUp: false)]),
                                    Column(
                                      children: [
                                        Text(
                                          "$averageYear ${S.of(context).km}",
                                          style: const TextStyle(color: Colors.green, fontSize: 20),
                                        ),
                                        Transform.translate(
                                          offset: const Offset(5, -5),
                                          child: Text(
                                            S.of(context).period,
                                            style: TextStyle(color: Colors.black87, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(S.of(context).month, style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 50),
                                Container(height: 20, width: 2, color: Colors.grey),
                                const SizedBox(width: 50),
                                Text(S.of(context).average, style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (state.expenseStats != null) ExpenseStatsCard(stats: state.expenseStats!),
            ],
          ),
        );
      },
    );
  }
}
