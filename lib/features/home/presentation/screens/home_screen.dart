// ignore_for_file: unnecessary_null_comparison

import 'package:auto_route/auto_route.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import '../widgets/expense_trend_card.dart';
import '../widgets/hero_expense_card.dart';
import '../widgets/quick_add_row.dart';
import '../widgets/fines_alert_card.dart';
import '../widgets/recent_transactions_list.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.brandTheme.surfaceBg,
      // No AppBar: the plate and car photo live in the hero card, and
      // settings moved to the bottom navigation.
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    BlocBuilder<StatisticsCubit, StatisticsState>(
                      builder: (context, state) {
                        if (state.loading &&
                            context.watch<CarCubit>().state.carId.isNotEmpty) {
                          return const CircularProgressIndicator();
                        }

                        final hasCar = context
                            .watch<CarCubit>()
                            .state
                            .carId
                            .isNotEmpty;

                        final stats = hasCar
                            ? MainStats(
                                totalCost: state.expenseStats.total,
                                monthMileage: state.currentMonthMileage,
                                averageFuelConsumption:
                                    state.averageFuelConsumption,
                                lastOdometer: state.lastOdometer,
                              )
                            : const MainStats(
                                totalCost: 0,
                                monthMileage: 0,
                                averageFuelConsumption: 0,
                                lastOdometer: 0,
                              );

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context
                              .findAncestorStateOfType<HomeScreenWrapperState>()
                              ?.openPage(HomePage.history),
                          child: HeroExpenseCard(
                            hasCar: hasCar,
                            state: state,
                            stats: stats,
                            // Opens Гараж (the vehicle list) - per the
                            // redesign, the plate and the car photo both
                            // open the garage.
                            onGarageTap: () => context
                                .findAncestorStateOfType<
                                  HomeScreenWrapperState
                                >()
                                ?.openPage(HomePage.garage),
                          ),
                        );
                      },
                    ),

                    AppSpacers.verticalMedium,
                    BlocBuilder<CarCubit, CarState>(
                      builder: (context, state) {
                        if (state.carId.isEmpty) return const SizedBox.shrink();
                        return const QuickAddRow();
                      },
                    ),

                    BlocBuilder<CarCubit, CarState>(
                      builder: (context, state) {
                        if (state.carId.isEmpty) return const SizedBox.shrink();
                        return const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: ExpenseTrendCard(),
                        );
                      },
                    ),

                    BlocBuilder<CarCubit, CarState>(
                      builder: (context, state) {
                        if (state.carId.isEmpty) return const SizedBox.shrink();
                        return const FinesAlertCard();
                      },
                    ),

                    BlocBuilder<CarCubit, CarState>(
                      builder: (context, state) {
                        if (state.carId.isEmpty) return const SizedBox.shrink();
                        return const RecentTransactionsList();
                      },
                    ),

                    AppSpacers.verticalXSmall,
                    BlocListener<CarCubit, CarState>(
                      listenWhen: (prev, curr) => prev.carId != curr.carId,
                      listener: (context, state) {
                        if (state.carNumber.isEmpty) {
                          context.read<StatisticsCubit>().clearStats();
                        }
                      },
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
