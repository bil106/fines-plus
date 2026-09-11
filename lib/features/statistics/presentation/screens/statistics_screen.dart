import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/expenses/presentation/widgets/expense_stats_card.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_state.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/settings/presentation/cubit/unit_stream.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final maintenanceCubit = context.read<MaintenanceCubit>();
        return StatisticsCubit(maintenanceCubit);
      },
      child: const _StatisticsScreenView(),
    );
  }
}

class _StatisticsScreenView extends StatelessWidget {
  const _StatisticsScreenView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final expenseStats = state.expenseStats;

        if (expenseStats.total == 0) {
          return Center(child: Text(S.of(context).no_expenses, style: Theme.of(context).textTheme.black16bold));
        }
        final monthLabel = state.expenseStats.monthLabel;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder: (_) {
                  return const SizedBox.shrink();
                },
              ),

              Card(
                shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).mileage_statistics, style: textTheme.black16bold),
                      const Divider(color: AppColors.neutreGrey),
                      AppSpacers.verticalSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car, size: 28, color: AppColors.energyBlue),
                              AppSpacers.horizontalSmallMedium,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(monthLabel, style: textTheme.black16bold),
                                  BlocSelector<MaintenanceCubit, MaintenanceState, int>(
                                    selector: (state) => context.read<MaintenanceCubit>().getAverageMileage(),
                                    builder: (context, averageMileage) {
                                      final settingsCubit = context.watch<SettingsCubit>();
                                      final unitStream = UnitStream(settingsCubit);

                                      return StreamBuilder<double>(
                                        stream: unitStream.unitValueStream(averageMileage.toDouble()),
                                        initialData: unitStream.convert(averageMileage.toDouble()),
                                        builder: (context, snapshot) {
                                          final value = snapshot.data ?? averageMileage.toDouble();
                                          final unit = settingsCubit.state.unit == 'mil' ? 'mil' : 'km';

                                          return Text(
                                            "${value.toStringAsFixed(0)} $unit",
                                            style: textTheme.black16bold,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              BlocSelector<MaintenanceCubit, MaintenanceState, int>(
                                selector: (state) => context.read<MaintenanceCubit>().getAverageMileage(),
                                builder: (context, averageMileage) {
                                  final settingsCubit = context.watch<SettingsCubit>();
                                  final unitStream = UnitStream(settingsCubit);

                                  return StreamBuilder<double>(
                                    stream: unitStream.unitValueStream(averageMileage.toDouble()),
                                    initialData: unitStream.convert(averageMileage.toDouble()),
                                    builder: (context, snapshot) {
                                      final value = snapshot.data ?? averageMileage.toDouble();
                                      final unit = settingsCubit.state.unit == 'mil' ? 'mil' : 'km';

                                      return Text("${value.toStringAsFixed(0)} $unit", style: textTheme.green20W400);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      AppSpacers.verticalSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(S.of(context).month, style: textTheme.grey12W400),
                          AppSpacers.horizontalMassive,
                          Container(height: 20, width: 2, color: AppColors.neutreGrey),
                          AppSpacers.horizontalMassive,
                          Text(S.of(context).average, style: textTheme.grey12W400),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacers.verticalSmall,

              ExpenseStatsCard(
                stats: state.expenseStats,
                onMaintenance: () =>
                    context.findAncestorStateOfType<HomeScreenWrapperState>()?.openPage(HomePage.maintenance),
              ),
            ],
          ),
        );
      },
    );
  }
}
