import 'package:core_cubit/cubit/maintenance/maintenance_cubit.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_state.dart';
import 'package:core_cubit/cubit/statistics/statistics_cubit.dart';
import 'package:core_cubit/cubit/statistics/statistics_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/widgets/expense_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    final now = DateTime.now();
    final maintenanceCubit = context.read<MaintenanceCubit>();

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        if (state.loading) return const Center(child: CircularProgressIndicator());

        return BlocBuilder<MaintenanceCubit, MaintenanceState>(
          builder: (context, maintenanceState) {
            final currentMonthMileage = maintenanceCubit.getCurrentMonthMileage(now);
            final averageMileage = maintenanceCubit.getAverageMileage();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).mileage_statistics,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 12),
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
                                        DateFormat('MMMM yyyy', 'uk').format(now),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "$currentMonthMileage ${S.of(context).km}",
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "$averageMileage ${S.of(context).km}",
                                    style: const TextStyle(color: Colors.green, fontSize: 20),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(5, -5),
                                    child: Text(
                                      S.of(context).period,
                                      style: const TextStyle(color: Colors.black87, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(S.of(context).month, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 50),
                              Container(height: 20, width: 2, color: Colors.grey),
                              const SizedBox(width: 50),
                              Text(S.of(context).average, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
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
      },
    );
  }
}
