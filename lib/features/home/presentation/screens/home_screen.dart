// ignore_for_file: unnecessary_null_comparison

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/home/domain/entities/last_event_ui_model.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/cubit/quick_actions_cubit.dart';
import 'package:fines_plus/features/home/presentation/widgets/quick_actions_panel.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_state.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/main_stats_card.dart';
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
  LastEventUiModel? latestExpense;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final carNumber = context.read<CarCubit>().state.carNumber;
    context.read<QuickActionsCubit>().syncActiveCategories(carNumber);
    context.read<QuickActionsCubit>().init();
    _loadLatestExpense();
  }

Future<void> _loadLatestExpense() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final repo = ExpenseRepository(FirebaseFirestore.instance);
    final carCubit = context.read<CarCubit>();

    final carNumber = carCubit.state.carNumber;

    if (carNumber == null || carNumber.isEmpty) {
      setState(() {
        latestExpense = null;
        isLoading = false;
      });
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('User not signed in, skipping ensureCarDocument');
      setState(() {
        latestExpense = null;
        isLoading = false;
      });
      return;
    }

   
    await repo.ensureCarDocument(carNumber);

    final allExpenses = await repo.getExpensesOnce(carNumber: carNumber);
    if (!mounted) return;

    if (allExpenses.isEmpty) {
      setState(() {
        latestExpense = null;
        isLoading = false;
      });
      return;
    }

    final allEvents = allExpenses.map((e) => LastEventUiModel.fromExpense(e)).toList();

   
    final latestByMileage = allEvents.reduce((a, b) => (a.mileage ?? 0) > (b.mileage ?? 0) ? a : b);

    if (!mounted) return;
    setState(() {
      latestExpense = latestByMileage;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          backgroundColor: AppColors.energyBlue50,
          centerTitle: true,
          title: BlocBuilder<CarCubit, CarState>(
            builder: (context, state) {
              final carNumber = state.carNumber.isNotEmpty ? state.carNumber : S.of(context).input_number;
              return Text(
                carNumber,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              );
            },
          ),
          leading: IconButton(
            icon: const Icon(Icons.settings, color: AppColors.grey700),
            onPressed: () {
              final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
              if (homeState != null) {
                homeState.openPage(HomePage.settings);
              }
            },
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(Icons.directions_car, size: 28, color: AppColors.grey700),
                onPressed: () {
                  final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                  wrapperState?.openPage(HomePage.carInfo);
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 4),
        child: Column(
          children: [
            BlocBuilder<StatisticsCubit, StatisticsState>(
              builder: (context, state) {
                if (state.loading) {
                  return const CircularProgressIndicator();
                }

                final hasCar = context.watch<CarCubit>().state.carNumber.isNotEmpty;

                final stats = hasCar
                    ? MainStats(
                        totalCost: state.expenseStats.total,
                        monthMileage: state.currentMonthMileage,
                        averageFuelConsumption: state.averageFuelConsumption,
                        lastOdometer: state.lastOdometer,
                      )
                    : const MainStats(totalCost: 0, monthMileage: 0, averageFuelConsumption: 0, lastOdometer: 0);

                return MainStatsCard(stats: stats);
              },
            ),

            AppSpacers.verticalXSmall,
            BlocListener<CarCubit, CarState>(
              listenWhen: (prev, curr) => prev.carNumber.isNotEmpty && curr.carNumber.isEmpty,
              listener: (context, state) {
                if (state.carNumber.isEmpty) {
                  setState(() {
                    latestExpense = null;
                    isLoading = false;
                  });
                  context.read<StatisticsCubit>().clearStats();
                  context.read<QuickActionsCubit>().clearAllActive();
                  return;
                }

                context.read<QuickActionsCubit>().syncActiveCategories(state.carNumber);
                _loadLatestExpense();
              },
              child: const QuickActionsPanel(),
            ),
            AppSpacers.verticalXSmall,

            Builder(
              builder: (context) {
                final carNumber = context.watch<CarCubit>().state.carNumber;
                if (carNumber.isEmpty) {
                  return LastEventCardAction(event: null, onTap: null, onOpenEvents: null);
                }

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return LastEventCardAction(
                  event: latestExpense,
                  onTap: () {},
                  onOpenEvents: () {
                    final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
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
    );
  }
}
