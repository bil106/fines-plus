import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/expenses/data/repository/expense_repository.dart';
import 'package:fines_plus/features/home/domain/entities/last_event_ui_model.dart';
import 'package:fines_plus/features/home/domain/entities/main_stats.dart';
import 'package:fines_plus/features/home/presentation/widgets/quick_actions_panel.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
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
    _loadLatestExpense();
  }

 Future<void> _loadLatestExpense() async {
    final repo = ExpenseRepository(FirebaseFirestore.instance);
    final carNumber = context.read<CarCubit>().state.carNumber;

    final expense = await repo.getLatestExpense(carNumber: carNumber);

    final eventUi = expense != null ? LastEventUiModel.fromExpense(expense) : null;

    setState(() {
      latestExpense = eventUi;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.energyBlue50,
        title: const Text(
          "Ford Fusion 2016",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.grey700),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car, color: AppColors.grey700),
            onPressed: () {
              final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
              wrapperState?.openPage(HomePage.carInfo);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 8),
        child: Column(
          children: [
            BlocBuilder<StatisticsCubit, StatisticsState>(
              builder: (context, state) {
                if (state.loading) return const CircularProgressIndicator();

                final lastOdometer = state.lastOdometer;
                final totalCost = state.expenseStats.total;
                final monthMileage = state.currentMonthMileage;
                final avgFuel = state.averageFuelConsumption;

                final stats = MainStats(
                  totalCost: totalCost,
                  monthMileage: monthMileage,
                  averageFuelConsumption: avgFuel,
                  lastOdometer: lastOdometer,
                );

                return MainStatsCard(stats: stats);
              },
            ),
            AppSpacers.verticalXSmall,
            const QuickActionsPanel(),
          

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              LastEventCardAction(
                event: latestExpense,
                onTap: () {},
                onOpenEvents: () {
                  final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                  wrapperState?.openPage(HomePage.maintenance);
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
