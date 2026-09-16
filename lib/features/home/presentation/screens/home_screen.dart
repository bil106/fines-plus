// ignore_for_file: unnecessary_null_comparison

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/garage_state.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/hero_expense_card.dart';
import '../widgets/quick_add_row.dart';
import '../widgets/fines_alert_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/last_event_card.dart';
import '../widgets/statistics_mileage_card.dart';
import '../widgets/statistics_costs_card.dart';

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
      backgroundColor: AppColors.energyBlue50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBar(
          elevation: 0,
          backgroundColor: AppColors.energyBlue50,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: BlocBuilder<CarCubit, CarState>(
              builder: (context, state) {
                final carNumber = state.carNumber.isNotEmpty
                    ? state.carNumber
                    : S.of(context).input_number;
                return Text(
                  carNumber,
                  // Big Shoulders Display - the Fines+OS mockup's headline
                  // token (.phone-h1/h1.title), applied to this screen's
                  // equivalent big heading.
                  style: GoogleFonts.bigShouldersDisplay(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  ),
                );
              },
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.settings, color: AppColors.grey700),
            iconSize: 30,
            padding: const EdgeInsets.all(14),
            onPressed: () {
              final homeState = context
                  .findAncestorStateOfType<HomeScreenWrapperState>();
              if (homeState != null) {
                homeState.openPage(HomePage.settings);
              }
            },
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: BlocBuilder<GarageCubit, GarageState>(
                builder: (context, garageState) {
                  final activeCars = garageState.cars.where(
                    (c) => c.carId == garageState.activeCarId,
                  );
                  final photoUrl = activeCars.isNotEmpty
                      ? activeCars.first.photoUrl
                      : '';

                  return IconButton(
                    icon: photoUrl.isEmpty
                        ? const Icon(
                            Icons.directions_car,
                            size: 28,
                            color: AppColors.grey700,
                          )
                        : ClipOval(
                            child: Image.network(
                              photoUrl,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.directions_car,
                                size: 28,
                                color: AppColors.grey700,
                              ),
                            ),
                          ),
                    onPressed: () {
                      final wrapperState = context
                          .findAncestorStateOfType<HomeScreenWrapperState>();
                      wrapperState?.openPage(HomePage.carInfo);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  BlocBuilder<CarCubit, CarState>(
                    builder: (context, state) {
                      if (state.carId.isEmpty) return const SizedBox.shrink();
                      return const QuickAddRow();
                    },
                  ),
                  AppSpacers.verticalSmallMedium,

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

                      return HeroExpenseCard(hasCar: hasCar, state: state, stats: stats);
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
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).recent_transactions,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const RecentTransactionsList(),
                          ],
                        ),
                      );
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

                  BlocBuilder<StatisticsCubit, StatisticsState>(
                    builder: (context, state) {
                      final carId = context.watch<CarCubit>().state.carId;
                      if (carId.isEmpty) {
                        return LastEventCardAction(
                          event: null,
                          onTap: null,
                          onOpenEvents: null,
                        );
                      }

                      if (state.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return LastEventCardAction(
                        event: state.lastEvent,
                        onTap: () {},
                        onOpenEvents: () {
                          final wrapperState = context
                              .findAncestorStateOfType<
                                HomeScreenWrapperState
                              >();
                          wrapperState?.openPage(HomePage.maintenance);
                        },
                      );
                    },
                  ),

                  StatisticsMileageCard(),

                  StatisticsCostsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
